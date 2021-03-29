################
# Analysis and visualizing of COVID-19 reported cases

###############
# libraries
library(ggplot2)
library(zoo) # rollmean function
library(dplyr)
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
regs = read.csv('data/interventions_pa_long.csv', header = TRUE)
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
# Centre County epidemiological data
epi_centre = read.csv('output/pa_centre_20210301.csv', header = TRUE)
epi_centre$Date = as.Date(epi_centre$Date, format = '%Y-%m-%d')
epi_centre$Date_adj = as.Date(epi_centre$Date_adj, format = '%Y-%m-%d')
epi_centre$phase2 = as.factor(epi_centre$phase2)
epi_centre$phase2 = factor(epi_centre$phase2, 
                            levels = c('base','pop','local','red','yellow', 'green','return'))
epi_centre = epi_centre[order(epi_centre$Date_adj),]


# traffic data
complete_vehicle = read.csv("output/predicted_observed_camera_data_20201215.csv", header = TRUE)
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
safe = read.csv('output/truncated_safegraph_for_epi.csv', header = TRUE)
safe$datetime_EST = as.POSIXct(safe$start_date, tz = "EST")
safe$date = as.Date(safe$date, format="%Y-%m-%d")
safe$phase = as.factor(safe$phase)
safe$phase = factor(safe$phase, 
                    levels = c('base','pop','local','red','yellow', 'green'))

########
phase_col = c('black', '#4e4e4e','#b4b4b5', '#a00707','#ecae20','#c3dfa1', '#810f7c')

traffic = ggplot(traffic_daily, aes(x=date, y=daily_total)) +
  geom_bar(aes(fill = phase), stat = 'identity',  col = 'white', lwd = 0.1) +
  geom_line(aes(y=rollmean(daily_total, 14, na.pad=TRUE))) +
  scale_shape_manual() + 
  scale_fill_manual(values= phase_col[4:7]) +
  scale_x_date(date_minor_breaks = "1 day", breaks = '14 days', 
               limits = as.Date(c("2020-03-01","2020-08-16")), 
               date_labels = '%b %e')+
  theme_bw(base_size = 13)+
  scale_y_continuous(limits = c(0,40000),expand = c(0, 0))+
  theme(axis.text.x = element_blank())+
  labs(x = '', y ='daily car volume') #+

traffic  
head(safe)
sf_plot =   ggplot(safe, aes(x=date, y=visit_counts_norm_loc)) +
  geom_bar(aes(fill = phase), stat = 'identity',  col = 'white', lwd = 0.1) +
  geom_line(aes(y=rollmean(visit_counts_norm_loc, 2, na.pad=TRUE))) +
  scale_fill_manual(values = phase_col[4:6])+
  scale_x_date(date_minor_breaks = "7 days", breaks = '2 weeks', 
               limits = as.Date(c("2020-03-01","2020-08-16")),
               date_labels = '%b %e')+
  theme_bw(base_size = 13)+
  theme(axis.text.x = element_blank())+
  labs(y = ' normalised visits ', x = '' )+
  scale_y_continuous(breaks = seq(0,10,by = 2), limits = c(0,10), expand = c(0, 0)) 
sf_plot

epi = ggplot(epi_centre, aes(x=Date_adj, y=New.Cases)) +
  geom_bar(aes(fill = phase2), stat = 'identity',  col = 'white', lwd = 0.1) +
  geom_line(aes(y=rollmean(New.Cases, 14, na.pad=TRUE))) +
  scale_fill_manual(values = phase_col) +
  scale_x_date(date_minor_breaks = "1 day", breaks = '14 days',
               limits = as.Date(c("2020-02-01","2020-08-16")),
               date_labels = '%b %e')+
  scale_y_continuous(limits = c(0,16), breaks = seq(0,16,by = 2))+
  theme_bw(base_size = 13)+
  labs(y = ' daily confirmed cases', x = '' )
epi

grid.newpage()
grid.draw(rbind(ggplotGrob(sf_plot), 
                ggplotGrob(traffic),
                ggplotGrob(epi), size = "last"))

###############
epi_centre$X7.day.Average.New.Cases

traffic_cases = merge(traffic_daily, epi_centre, by.x = 'date', by.y = 'Date', all.x = TRUE )  
traffic_safe_cases = merge(traffic_cases, safe, by = 'date')
plot(traffic_safe_cases$daily_total, traffic_safe_cases$New.Cases)
points(traffic_safe_cases$date, traffic_safe_cases$X7.day.Average.New.Cases, type = 'l', add = TRUE)

ccfvalues = ccf(traffic_cases$daily_total,traffic_cases$X7.day.Average.New.Cases, 21)
ccfvalues$lag[ccfvalues$acf == max(ccfvalues$acf)]

ccfvalues = ccf(traffic_safe_cases$visit_counts_norm_loc,traffic_safe_cases$X7.day.Average.New.Cases, 21)
ccfvalues$acf == max(ccfvalues$acf)
ccfvalues$lag[ccfvalues$acf == max(ccfvalues$acf)]



