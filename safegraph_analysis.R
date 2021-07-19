#######################
library(ggplot2)
centre_daily = read.csv('raw_data/daily_visits_CentreCounty_CBGs.csv', header = TRUE)

#formatting dates
centre_daily$date_format =as.Date(centre_daily$date, format = '%Y-%m-%d')
head(centre_daily)


centre_daily$weekday = weekdays(centre_daily$date_format)
centre_daily$weekday = as.factor(centre_daily$weekday)
centre_daily$weekday =factor(centre_daily$weekday,
                             levels = c('Friday','Saturday','Sunday',
                                        'Monday','Tuesday',
                                        'Wednesday','Thursday'))
centre_daily$year = as.factor(format(centre_daily$date_format, format ='%Y'))
centre_daily$month = as.factor(format(centre_daily$date_format, format ='%m'))

ggplot(centre_daily,aes(month,visit_counts, fill = weekday))+
  geom_boxplot()+
  facet_grid(year~.)+
  theme_bw()
ggplot(centre_daily,aes(weekday,visit_counts))+
  geom_boxplot()+
  facet_grid(year~.)

source('phase_functions.R')

centre_daily$phase = getphase3(centre_daily$date_format)
centre_daily$phase = as.factor(centre_daily$phase)
centre_daily = centre_daily[!(centre_daily$phase %in% c('base1','return')),]
centre_daily = centre_daily[!is.na(centre_daily$phase),]
centre_daily$phase = factor(centre_daily$phase,
                            levels = c('base','pop','local',
                                       'red','yellow','green'))
centre_daily$phase

library(dplyr)

centre_sum = centre_daily %>%
  group_by(phase, year, weekday) %>%
  summarise(days = length(visit_counts))

centre_daily$weekend = centre_daily$weekday %in% c('Saturday','Sunday')
centre_sum2 = centre_daily %>%
  group_by(phase, year, weekend) %>%
  summarise(days = length(visit_counts),
            mean_visit = mean(visit_counts))

ggplot(centre_sum,aes(days))+
  geom_histogram(aes(fill = weekday))+
  facet_grid(year~phase)

centre_daily = centre_daily %>% 
  group_by(year) %>% 
  arrange(date_format, .by_group = TRUE) %>%
  mutate(day_index = 1:182)

ggplot(centre_daily,aes(day_index,visit_counts))+
  geom_point(aes(col = phase, shape = weekday))+
  facet_grid(year~.)+
  theme_bw()

centre_daily_twoyrs = centre_daily[centre_daily$year %in% c(2019,2020),]
ggplot(centre_daily_twoyrs,aes(day_index,visit_counts))+
  geom_point(aes(col = phase, shape = weekday))+
  facet_grid(year~.)+
  theme_bw()
centre_daily_twoyrs = merge(indexes_2020, centre_daily_twoyrs,by = 'day_index')

ggplot(centre_daily_twoyrs,aes(date_format.x,visit_counts))+
  geom_point(aes(col = phase), method = 'gam')+
  facet_grid(year~.)+
  geom_smooth(col = 'grey50', method = 'gam')+
  scale_color_manual(values = phase_col)+ 
  theme_bw()

#######
#removing 2018
library(tidyr)
names(centre_daily)
centre_daily_long = centre_daily[,c('day_index', 'phase', 'weekday','year','visit_counts')]
centre_daily_wide = spread(centre_daily_long, year, visit_counts)
centre_daily_wide$diff_18_19 = centre_daily_wide$'2019'-centre_daily_wide$'2018'
centre_daily_wide$diff_20_19 = centre_daily_wide$'2020'-centre_daily_wide$'2019'
centre_daily_wide$pan = centre_daily_wide$'2020'
indexes_2020 = centre_daily[centre_daily$year == '2020',c('date_format', 'day_index')]
centre_daily_wide = merge(indexes_2020, centre_daily_wide)

mean_phases = centre_daily_wide %>% 
  group_by(phase) %>% 
  summarise(mean_exp = mean(diff_20_19),
            mean_visit = mean(pan, na.rm = TRUE),
            med_visit = median(pan, na.rm = TRUE),
            median_exp = median(diff_20_19),
            st_date = min(date_format),
            end_date = max(date_format))
centre_students = as.numeric(mean_phases[mean_phases$phase=='base','mean_exp'])
centre_students_med = as.numeric(mean_phases[mean_phases$phase=='base','median_exp'])
centre_nostudents = as.numeric(mean_phases[mean_phases$phase=='pop','mean_exp'])
centre_nostudents_med = as.numeric(mean_phases[mean_phases$phase=='pop','median_exp'])

ggplot(centre_daily_wide,aes(date_format,diff_20_19))+
  geom_smooth(col = 'grey50', method = 'gam')+
  geom_hline(yintercept=centre_students, col = 'black', lwd = 0.3)+
  geom_hline(yintercept=centre_nostudents, col = 'black',  lwd = 0.3)+
  geom_segment(x=as.Date('2020-02-14'),xend=as.Date('2020-03-05'),
               y=centre_students,yend=centre_students,lwd = 1.2)+
  geom_segment(x=as.Date('2020-03-16'),xend=as.Date('2020-05-07'),
               y=centre_students,yend=centre_students,lwd = 1.2)+
  geom_segment(x=as.Date('2020-03-06'),xend=as.Date('2020-03-15'),
               y=centre_nostudents,yend=centre_nostudents, lwd = 1.2)+
  geom_segment(x=as.Date('2020-05-08'),xend=as.Date('2020-08-13'),
               y=centre_nostudents,yend=centre_nostudents, lwd = 1.2)+
  geom_point(aes(col = phase), alpha = 0.9, size = 2, stroke =0)+
  scale_color_manual(values = phase_col)+ 
  theme_bw()+
  scale_y_continuous(breaks = seq(-20000, 15000, by= 5000))+
  scale_x_date(date_minor_breaks = "7 day", breaks = '14 days', #limits = as.Date(c("2020-03-01","2020-11-10")), 
               date_labels = '%b %e')+
  labs(x = '2020 date', y = 'difference in visits compared to 2019')+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

write.csv(centre_daily_wide,'output/centre_daily_wide.csv', row.names = FALSE )


phase_col = c('black','grey90', 
              '#b4b4b5', '#a00707','#ecae20', '#c3dfa1')

ggplot(centre_daily_wide,aes(phase,diff_20_19))+
  geom_hline(yintercept=centre_students_med, col = 'black', lwd = 0.3)+
  geom_hline(yintercept=centre_nostudents_med, col = 'black',  lwd = 0.3)+
  geom_violin(aes(fill = phase), width = 1.5)+
  geom_boxplot(varwidth = TRUE, color = 'grey10', lwd = 0.2, outlier.shape = NA)+
  scale_fill_manual(values = phase_col)+ 
  theme_bw()+
  scale_y_continuous(breaks = seq(-20000, 15000, by= 5000))+
  labs(x = 'temporal phase', y = 'difference in 2020 visits compared to 2019')+
  theme(legend.position = "none")

ggplot(centre_daily_wide,aes(date_format,diff_18_19))+
  geom_smooth(col = 'black', method = 'gam')+
  geom_hline(yintercept=0)+
  geom_point(aes(col = phase), alpha = 0.9, size = 2, stroke =0)+
  scale_color_manual(values = phase_col)+ 
  theme_bw()+
  scale_x_date(date_minor_breaks = "7 day", breaks = '14 days', #limits = as.Date(c("2020-03-01","2020-11-10")), 
               date_labels = '%b %e')+
  labs(x = '2020 date', y = 'difference in visits (2019-2018)')+
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(centre_daily_wide,aes(phase,diff_18_19))+
  geom_violin(aes(fill = phase))+
  geom_boxplot(width = 0.1, color = 'grey10', lwd = 0.2, outlier.shape = NA)+
  geom_hline(yintercept=0)+
  scale_fill_manual(values = phase_col)+ 
  theme_bw()+
  labs(x = 'temporal phase', y = 'mean difference in visits (2019-2018)')