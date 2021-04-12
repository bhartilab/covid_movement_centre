################
# Analysis and visualizing of COVID-19 reported cases

###############
# libraries
library(ggplot2)
library(zoo) # rollmean function
library(dplyr)

library(cowplot)
library(grid)
library(gridExtra)

###############
# County level patterns for Centre and surrounding counties
epi_counties = read.csv('output/pa_central_20210301.csv', header = TRUE)

epi_counties$Date = as.Date(epi_counties$Date, format = '%Y-%m-%d')
epi_counties$Jurisdiction = as.factor(epi_counties$Jurisdiction)
#reorder for plotting
# goes from latest enactment of restrictions to earliest
epi_counties$Jurisdiction = factor(epi_counties$Jurisdiction,
                                     levels = c('Huntingdon', 'Mifflin',
                                                'Blair', 'Union', 'Clinton',
                                                'Clearfield','Centre'))


# timeline of interventions for each county (different times for each)
# timing of interventions from: https://www.governor.pa.gov/process-to-reopen-pennsylvania/
regs = read.csv('raw_data/interventions_pa_long.csv', header = TRUE)
regs$start_date = as.Date(regs$start_date, format = "%m/%d/%y")
regs$phases = as.factor(regs$phases)
regs$phases = factor(regs$phases,
                     levels = c('red','yellow','green'))
# have to turn Jurisdiction into a factor and reorder for plotting
regs$Jurisdiction = as.factor(regs$Jurisdiction)
regs$Jurisdiction = factor(regs$Jurisdiction,
                           levels = c('Huntingdon', 'Mifflin',
                                      'Blair', 'Union', 'Clinton',
                                      'Clearfield','Centre')) 


ggplot(epi_counties, aes(x=Date, y=New.Cases)) +
  geom_segment(data = regs, aes(x = start_date, y = -Inf, 
                                xend = start_date, yend = Inf, col = phases), 
               alpha = 0.5, lwd = 1.2)+
  geom_area()+
  facet_wrap(~Jurisdiction, ncol = 1)+ 
  scale_x_date(expand=c(0,0),
               date_breaks= "2 weeks", 
               limits = as.Date(c("2019-12-30","2020-08-30")), 
               date_labels = '%b %e')+
  theme_classic()+
  theme(strip.background = element_blank(),
        strip.text.x = element_blank())+
  scale_color_manual(values = c('darkred','darkgoldenrod','darkgreen'))+
  labs(x = 'date of confirmed test', y = 'new cases')


###############

centre_phases = read.csv('raw_data/phase_centre_co.csv', header = TRUE)
centre_phases$start_date = as.Date(centre_phases$start_date, format = '%m/%d/%y')
centre_phases$end_date = as.Date(centre_phases$end_date, format = '%m/%d/%y')
centre_phases$phases = factor(centre_phases$phases,
                              levels = c('base','pop','local','red','yellow', 'green'))
head(centre_phases)
###############
# Centre County epidemiological data
epi_centre = read.csv('output/pa_centre_20210301.csv', header = TRUE)
epi_centre$Date = as.Date(epi_centre$Date, format = '%Y-%m-%d')
epi_centre$Date_adj = as.Date(epi_centre$Date_adj, format = '%Y-%m-%d')
epi_centre$phase = getphase(epi_centre$Date)
epi_centre$phase = factor(epi_centre$phase, 
                           levels = c('base','pop','local','red','yellow', 'green','return'))
epi_centre[epi_centre$phase =='return','phase'] <- as.factor('green')
epi_centre$phase2 = as.factor(epi_centre$phase2)
epi_centre$phase2 = factor(epi_centre$phase2, 
                            levels = c('base','pop','local','red','yellow', 'green','return'))
epi_centre = epi_centre[order(epi_centre$Date),]


# traffic data
complete_vehicle = read.csv("output/predicted_observed_camera_data.csv", header = TRUE)
complete_vehicle$date = as.Date(complete_vehicle$date)
complete_vehicle$datetime_EST = as.POSIXct(complete_vehicle$datetime_EST, tz = "EST")
complete_vehicle$phase = getphase(complete_vehicle$date)
complete_vehicle$phase = factor(complete_vehicle$phase, levels = c('red','yellow','green'))
traffic_daily_by_camera= as.data.frame(complete_vehicle %>%
                                         group_by(date, camera_name, phase) %>%
                                         summarise(daily_total = sum(vehicle_avg, na.rm = TRUE )))
traffic_daily = as.data.frame(complete_vehicle %>%
                                group_by(date, phase) %>%
                                summarise(daily_total = sum(vehicle_avg, na.rm = TRUE )))

# Safe Graph
safe = read.csv('output/safegraph_centre_daily_wide.csv', header = TRUE)
safe$date_format = as.Date(safe$date_format, format="%Y-%m-%d")
safe$phase = as.factor(safe$phase)
safe$phase = factor(safe$phase, 
                    levels = c('base','pop','local','red','yellow', 'green'))
head(safe)
########
phase_col = c('black', '#4e4e4e','#b4b4b5', '#a00707','#ecae20','#c3dfa1', '#810f7c')

#traffic = 
date_lim = as.Date(c("2020-02-13","2020-08-28"))
breaks_date = seq(as.Date("2020-02-14"), as.Date("2020-08-27"), by="7 days")

traffic_daily$daily_total
traffic = ggplot(traffic_daily, aes(x=date, y=daily_total)) +
  geom_rect(data=centre_phases, aes(NULL,NULL,xmin=start_date-.5,xmax=end_date+.5,fill=phases),
            ymin=0,ymax=40000, colour="white", size=0, alpha=0.5) +
  geom_bar(stat = 'identity',  fill = 'white', lwd = 0) +
  geom_line(aes(y=rollmean(daily_total, 7, na.pad=TRUE))) +
  scale_shape_manual() +
  scale_fill_manual(values= phase_col) +
  scale_x_date(date_minor_breaks = "1 day", 
               breaks = breaks_date,
               limits = date_lim)+
  theme_bw(base_size = 13)+
  scale_y_continuous(limits = c(0,40000),breaks = seq(0,40000, by= 5000),expand = c(0, 0))+
  theme(axis.text.x = element_blank())+
  labs(x = '', y ='daily car volume') #+

traffic  
head(safe)
sf_plot =   ggplot(safe, aes(x=date_format, y=diff_20_19)) +
  geom_rect(data=centre_phases, aes(NULL,NULL,xmin=start_date-.5,xmax=end_date+.5,fill=phases),
            ymin=-20000,ymax=15000, colour="white", 
            size=0, alpha=0.5) +
  geom_bar( stat = 'identity',  fill = 'white', lwd = 0) +
  geom_line(aes(y=rollmean(diff_20_19, 7, na.pad=TRUE))) +
  scale_fill_manual(values = phase_col)+
  scale_x_date(date_minor_breaks = "1 day", 
               breaks = breaks_date,
               limits = date_lim)+
  theme_bw(base_size = 13)+
  theme(axis.text.x = element_blank())+
  labs(y = ' normalised visits ', x = '' )+
  scale_y_continuous(breaks = seq(-20000, 15000, by= 5000))

sf_plot
epi = ggplot(epi_centre, aes(x=Date, y=New.Cases)) +
  geom_rect(data=centre_phases, aes(NULL,NULL,xmin=start_date-0.5,xmax=end_date+0.5,fill=phases),
            ymin=0,ymax=16, colour="white", size=0, alpha=0.5) +
  geom_bar(stat = 'identity',  fill = 'white', lwd = 0) +
  geom_line(aes(y=rollmean(New.Cases, 7, na.pad=TRUE))) +
  scale_fill_manual(values = phase_col) +
  scale_x_date(date_minor_breaks = "1 day", 
               breaks = breaks_date,
               limits = date_lim,
               date_labels = '%b %e')+
  scale_y_continuous(limits = c(0,16), breaks = seq(0,16,by = 2), expand = c(0, 0))+
  theme_bw(base_size = 13)+
  labs(y = ' daily confirmed cases', x = '' )+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
epi

grid.newpage()

grid.draw(rbind(ggplotGrob(sf_plot), 
                ggplotGrob(traffic), 
                ggplotGrob(epi),
                size = "last"))


grid.arrange(sf_plot,
             traffic,
             epi, ncol = 1)

###############
epi_centre$X7.day.Average.New.Cases

traffic_cases = merge(traffic_daily, epi_centre, by.x = 'date', by.y = 'Date', all.x = TRUE )  
traffic_safe_cases = merge(traffic_cases, safe, by = 'date', by.y = 'date_format')
plot(traffic_safe_cases$daily_total, traffic_safe_cases$New.Cases)
points(traffic_safe_cases$date, traffic_safe_cases$X7.day.Average.New.Cases, type = 'l', add = TRUE)

ccfvalues = ccf(traffic_safe_cases$daily_total,traffic_safe_cases$X7.day.Average.New.Cases, 28)
ccfvalues$lag[ccfvalues$acf == max(ccfvalues$acf)]

ccfvalues = ccf(traffic_safe_cases$diff_20_19,traffic_safe_cases$X7.day.Average.New.Cases, 28)
ccfvalues$acf == max(ccfvalues$acf)
ccfvalues$lag[ccfvalues$acf == max(ccfvalues$acf)]



