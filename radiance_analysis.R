#######################
# Radiance Analysis
######################
# libraries
library(raster)
library(reshape2)
library(ggplot2)
library(purrr)
library(dplyr)
source('phase_functions.R')
######################
# directory locations (some files outside of github due to size)
out_dir = "/Users/cfaust/Documents/workspace/pageocov_large_files/output"

#####################
# importing geotiffs 
daily_df = read.csv('output/radiance_index_dataframe.csv', header = TRUE)

state_daily_stack = stack(file.path(out_dir,"state_daily_stack_wmoon.grd"))
bellefonte_daily_stack = stack(file.path(out_dir,"bellefonte_daily_stack_wmoon.grd"))
bellefonte_df = as.data.frame(rasterToPoints(bellefonte_daily_stack))
state_df = as.data.frame(rasterToPoints(state_daily_stack))
head(state_df)
bellefonte_long = melt(bellefonte_df, id.vars=c("x", "y"),
                        variable.name="daily_id", value.name="radiance")
state_long = melt(state_df, id.vars=c("x", "y"),
                   variable.name="daily_id", value.name="radiance")
bellefonte_long$area = 'bellefonte'
state_long$area = 'state college'

# full dataset
summary_daily = rbind(state_long, bellefonte_long)
summary_daily$daily_id
summary_daily$date = gsub("vnp46a1.", "", summary_daily$daily_id)
summary_daily$date = as.Date(gsub(".clipped.centre.county", "", summary_daily$date), format = '%Y%m%d')
summary_daily$year = as.numeric(format(summary_daily$date, format = '%Y'))
summary_daily$year_fac = as.factor(summary_daily$year)
summary_daily$phase = getphase(summary_daily$date)
summary_daily$phase = as.factor(summary_daily$phase)
# base base1 green local pop red return yellow
phases_to_omit = c('base1', 'return')
summary_daily = summary_daily[!(summary_daily$phase %in% phases_to_omit),] #removes 580450 rows
summary_daily$phase = factor(summary_daily$phase, 
                          levels =c('base','pop','local',
                                    'red','yellow','green'))

summary_daily$date_plot = as.Date(strftime(summary_daily$date, format="2020-%m-%d")) 

summary_daily
summary_daily_mean = summary_daily %>% 
  group_by(date, date_plot, phase, area, year_fac) %>% 
  dplyr::summarise(rad_mean = mean(radiance, na.rm = TRUE),
                   rad_sd = sd(radiance, na.rm = TRUE),
                   rad_var = var(radiance, na.rm = TRUE),
                   pixels = sum(!is.na(radiance)))

full_moon = read.csv('raw_data/fullmoon_buffers.csv')
for (i in 2:ncol(full_moon)){
  full_moon[,i] =as.Date(full_moon[,i], format = "%m/%d/%y")
}
full_moon_5day_even = c(full_moon$full_moon_less2,full_moon$full_moon_less1,
                        full_moon$full_moon_date,
                        full_moon$full_moon_more1,full_moon$full_moon_more2) 
class(summary_daily_mean$date)
summary_daily_mean$full_moon = summary_daily_mean$date %in% full_moon_5day_even

daily_statecollege =summary_daily_mean[summary_daily_mean$area == 'state college',]
daily_statecollege = daily_statecollege[daily_statecollege$pixels> (max(daily_statecollege$pixels)/3),]
daily_bellefonte = summary_daily_mean[summary_daily_mean$area == 'bellefonte',]
daily_bellefonte = daily_bellefonte[daily_bellefonte$pixels> (max(daily_bellefonte$pixels)/3),]
phase_col = c('black', '#4e4e4e','#b4b4b5', '#a00707','#ecae20','#c3dfa1', '#810f7c')
summary_daily_mean_v2 = summary_daily_mean[summary_daily_mean$pixels>50,]

ggplot(daily_statecollege, aes(x =date_plot, rad_mean, col = phase, group = area))+ 
  geom_errorbar(aes(ymin=rad_mean-rad_sd, ymax=rad_mean+rad_sd), width=.2,
                position=position_dodge(.9)) +
  geom_point(col = 'white')+ # aes(shape = full_moon)
  geom_point(aes(shape = full_moon))+ # aes(shape = full_moon)
  scale_shape_manual(values=c(19,1))+
  theme_bw()+
  #scale_y_continuous(breaks = seq(-10,120,by=10), expand = c(0,0))+#limits = c(0,110),
  facet_grid(year_fac~.)+ #scales = 'free_y',ncol = 1
  scale_color_manual(values = phase_col)+
  labs(y = 'mean radiance (nW/cm2)', x = 'date', 
       fill = 'restriction \nphase')+
  scale_x_date(date_minor_breaks = "1 day", breaks = '1 month', 
               date_labels = '%b %d')
  

########################
# quartiles

ggplot(quarts, aes(x =phase, max, col = quartile, group = year_fac, fill = year_fac))+ 
  geom_crossbar(aes(ymin=min, ymax=max ), position=position_dodge(0.9)) +
  theme_classic()+
  scale_y_continuous(breaks = seq(0,110,by=10), expand = c(0,0))+#limits = c(0,110),
  facet_wrap(area~.,  scales = 'free_y')+ #scales = 'free_y',ncol = 1
  scale_fill_manual(values = yr_col)+
  scale_color_manual(values = c('grey70','grey50','grey30', 'grey10'))+
  labs(y = 'radiance (nW/cm2)', x = 'restriction phases', 
       fill = 'year')
