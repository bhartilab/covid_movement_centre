##################
# GAMS to predict missing data

############
# libraries
library(mgcv)
library(ggplot2)
library(tidyr) 

source('phase_functions.R') # function to define phase

##########
# import 
long_traffic = read.csv("output/vehicle_avg_per_hour_cleaned.csv", header = TRUE)
long_traffic$datetime_EST = as.POSIXct(long_traffic$datetime_EST, tz = "EST")
long_traffic$date = as.Date(long_traffic$date)
long_traffic$phase = as.factor(long_traffic$phase)
long_traffic$phase = factor(long_traffic$phase, levels = c('red', 'yellow','green'))
long_traffic$camera_name = as.factor(long_traffic$camera_name)

long_traffic$vehicle_avg_round = round(long_traffic$vehicle_avg)

max(long_traffic$date) - min(long_traffic$date)

################
# GAMS

gam_mod1 <- gam(vehicle_avg_round ~ camera_name + s(hour, bs = "cc"), data = long_traffic, family = 'poisson') 
summary(gam_mod1)
coef(gam_mod1)
plot(gam_mod1, pages=1, cex = 0.5)
plot(gam_mod1, residuals = TRUE, pch = 1, pages=1)

gam_mod1a <- gam(vehicle_avg_round ~ camera_name + s(hour, bs = "cc"), data = long_traffic, family = 'poisson') 
summary(gam_mod1a)

gam_mod2 <- gam(vehicle_avg_round ~ camera_name + weekends + s(hour, bs = "cc", by = camera_name), data = long_traffic) 
summary(gam_mod2)

gam_mod3 <- gam(vehicle_avg_round ~ camera_name + weekends + s(hour, by = camera_name) + s(date), data = long_traffic) 
summary(gam_mod3)

gam_mod4 <- gam(vehicle_avg_round ~ camera_name + weekends + road_connect*phase + s(hour, by = camera_name, bs = "cc"), data = long_traffic, family = 'poisson') 
summary(gam_mod4)
gam.check(gam_mod4)
plot(gam_mod4, pages=1, cex = 0.5)
par(mfrow=c(5,4))
plot(gam_mod4,shade=TRUE,
     seWithMean=TRUE, scale=0, 
     ylim = c(-8,4), xlim = c(0,24))
formula.gam(gam_mod4)
coef(gam_mod4)

######## 
# identify missing hours
long_traffic_trun = long_traffic[, c('datetime_EST', 'camera_name', 'vehicle_avg')]
wide_traffic_trun = spread(long_traffic_trun, camera_name, vehicle_avg)
traffic_trun_missing = gather(wide_traffic_trun, camera_name, vehicle_avg, CAM02001CCTV2:parkArboretum, factor_key=TRUE)
dim(traffic_trun_missing)
traffic_trun_missing = traffic_trun_missing[is.na(traffic_trun_missing$vehicle_avg),]
dim(traffic_trun_missing)
(2959/49685)*100
length(unique(traffic_trun_missing$camera_name))
traffic_trun_missing$datetime_EST = as.POSIXct(traffic_trun_missing$datetime_EST, tz = "EST")
traffic_trun_missing$date = as.Date(traffic_trun_missing$datetime_EST, format="%y-%m-%d")
traffic_trun_missing$hour = format(traffic_trun_missing$datetime_EST, format='%H')
traffic_trun_missing$hour = as.numeric(traffic_trun_missing$hour)
traffic_trun_missing$phase = getphase(traffic_trun_missing$date)
traffic_trun_missing$phase = factor(traffic_trun_missing$phase,
                                    levels=c("red","yellow","green"))
traffic_trun_missing$weekdays = weekdays(traffic_trun_missing$datetime_EST)
traffic_trun_missing$weekends = traffic_trun_missing$weekdays %in% c("Sunday", "Saturday")

camera_data = read.csv("raw_data/camera_IDs_locations.csv", header = TRUE)
camera_data$camera_name = gsub(".jpg","",camera_data$ID)
camera_data_trun = camera_data[,c('camera_name','road_connect','lanes')]
traffic_trun_missing = merge(traffic_trun_missing, camera_data_trun)
traffic_trun_missing

gam4_predict <- as.data.frame(predict(gam_mod4, traffic_trun_missing, type = "response", se.fit = TRUE))
gam4_predict_data = cbind(traffic_trun_missing,gam4_predict)
head(gam4_predict_data)
ggplot(gam4_predict_data, aes(x = hour, y = fit, group = camera_name)) +
  geom_point(aes(color=camera_name))+
  #geom_line(aes(hour, fit))+
  facet_wrap(~phase, ncol = 1)+
  theme_classic()

#combine fitted and observed data 
gam4_predict_data$obs_type = 'predicted'
gam4_predict_data$vehicle_avg <- NULL
gam4_predict_data$vehicle_avg <- gam4_predict_data$fit
names(gam4_predict_data)
long_traffic2 = long_traffic[,c('camera_name','datetime_EST', 'vehicle_avg')]
long_traffic2$obs_type = 'observed'
head(long_traffic)
head(gam4_predict_data)
gam4_predict_data2 = gam4_predict_data[,c('camera_name','datetime_EST', 'obs_type','vehicle_avg')]

complete_vehicle = dplyr::bind_rows(long_traffic2,gam4_predict_data2)
names(complete_vehicle)

complete_vehicle = merge(complete_vehicle, camera_data_trun, by.x = 'camera_name', by.y = 'camera_name')

complete_vehicle$date = as.Date(complete_vehicle$datetime_EST, format="%y-%m-%d")
complete_vehicle$hour = format(complete_vehicle$datetime_EST, format='%H')
complete_vehicle$hour = as.numeric(complete_vehicle$hour)
complete_vehicle$phase = getphase(complete_vehicle$date)
complete_vehicle$weekdays = weekdays(complete_vehicle$date)
weekdays = unique(complete_vehicle$weekdays)[order(unique(complete_vehicle$weekdays))]
weekend_days = weekdays[c(3,4)]
complete_vehicle$weekends = complete_vehicle$weekdays %in% weekend_days
head(complete_vehicle)

write.csv(complete_vehicle,"output/predicted_observed_camera_data.csv", row.names = FALSE)


##############
# hourly predictions for red vs green
# dummy dataset for hourly datasets 
dummy_dat <- data.frame(camera_name=rep(camera_data_trun$camera_name,24),
                        hour=rep(seq(0,23,by=1),each = 19)) 
dummy_dat$phase = 'green'
dummy_dat2 <- data.frame(camera_name=rep(camera_data_trun$camera_name,24),
                         hour=rep(seq(0,23,by=1),each = 19)) 
dummy_dat2$phase = 'red'
dummy_dat = rbind(dummy_dat, dummy_dat2)
dummy_dat$weekends = FALSE
dummy_dat_merged = merge(dummy_dat, camera_data_trun)
dummy_dat_predict <- as.data.frame(predict(gam_mod4, dummy_dat_merged, type = "response", se.fit = TRUE))
dummy_dat_predict_full = cbind(dummy_dat_merged, dummy_dat_predict)

write.csv(dummy_dat_predict_full, "output/gam4_predicted_hourly_green_red.csv", row.names = FALSE)

