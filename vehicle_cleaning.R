##########
# Code to clean and truncate vehicle count data
##########
source('phase_functions.R') # function to define phase

########
# import and format dataframe
long_traffic = read.csv('raw_data/vehicle_avg_per_hour_each_camera_427-921.csv', header = T)
long_traffic$datetime_EST = as.POSIXct(long_traffic$datetime_EST, tz = "EST")
long_traffic$date = as.Date(long_traffic$datetime_EST, format="%y-%m-%d")
long_traffic$hour = format(long_traffic$datetime_EST, format='%H')
long_traffic$hour = as.numeric(long_traffic$hour)
long_traffic$phase = getphase(long_traffic$date)
long_traffic$phase = factor(long_traffic$phase, levels = c('red','yellow','green','return'))
long_traffic$weekdays = weekdays(long_traffic$datetime_EST)
long_traffic$weekends = long_traffic$weekdays %in% c("Sunday", "Saturday")
head(long_traffic)
range(long_traffic$date)
long_traffic = long_traffic[long_traffic$date < as.Date("2020-08-14"),]

#CAM02002CCTV3
long_traffic[long_traffic$camera_name == 'CAM02002CCTV3' & long_traffic$datetime_EST > as.POSIXct('2020-05-24 07:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-26 12:00:00', tz = "EST"),'vehicle_avg'] <-NA

long_traffic[long_traffic$camera_name == 'CAM02005CCTV9' & long_traffic$datetime_EST > as.POSIXct('2020-05-17 17:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-20 13:00:00', tz = "EST"), 'vehicle_avg'] <-NA
long_traffic[long_traffic$camera_name == 'CAM02005CCTV9' & long_traffic$datetime_EST > as.POSIXct('2020-05-25 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-27 09:00:00', tz = "EST"), 'vehicle_avg'] <-NA

long_traffic[long_traffic$camera_name == 'CAM02006CCTV10' & long_traffic$datetime_EST > as.POSIXct('2020-06-11 18:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-06-13 05:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02006CCTV10' & long_traffic$datetime_EST > as.POSIXct('2020-05-17 16:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-20 13:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02006CCTV10' & long_traffic$datetime_EST > as.POSIXct('2020-05-25 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-27 09:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02006CCTV10' & long_traffic$datetime_EST > as.POSIXct('2020-07-06 09:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-08 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02006CCTV10' & long_traffic$datetime_EST > as.POSIXct('2020-08-25 20:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-27 09:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s

long_traffic[long_traffic$camera_name == 'CAM02007CCTV13' & long_traffic$datetime_EST > as.POSIXct('2020-06-22 18:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-21 18:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s

long_traffic[long_traffic$camera_name == 'CAM02009CCTV7' & long_traffic$datetime_EST > as.POSIXct('2020-07-22 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-23 16:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02009CCTV7' & long_traffic$datetime_EST > as.POSIXct('2020-07-27 10:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-29 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02009CCTV7' & long_traffic$datetime_EST > as.POSIXct('2020-08-05 12:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-07 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02009CCTV7' & long_traffic$datetime_EST > as.POSIXct('2020-08-18 11:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-19 16:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02009CCTV7' & long_traffic$datetime_EST > as.POSIXct('2020-08-18 11:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-19 16:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s

long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-05-30 04:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-31 05:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-06-03 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-06-05 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-06-17 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-06-20 06:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-06-22 12:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-06-23 15:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-06-30 14:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-02 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-06-28 13:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-06-29 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-07-25 23:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-29 17:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-08-12 10:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-14 20:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 12s
long_traffic[long_traffic$camera_name == 'CAM02020CCTV24' & long_traffic$datetime_EST > as.POSIXct('2020-08-22 12:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-25 16:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 180

long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-05-15 07:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-18 12:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-05-24 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-26 11:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-07-25 12:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-26 05:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-07-26 11:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-29 03:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-07-29 17:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-30 15:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-07-30 17:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-07-31 03:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-01 12:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-01 20:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-02 09:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-05 02:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-05 15:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-05 22:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-06 14:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-08 02:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s

long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-09 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-14 10:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-18 09:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-18 20:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-08-19 14:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-08-19 20:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s
long_traffic[long_traffic$camera_name == 'CAM02028CCTV32' & long_traffic$datetime_EST > as.POSIXct('2020-05-24 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-26 11:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s

long_traffic[long_traffic$camera_name == 'CAM02046CCTV52' & long_traffic$datetime_EST > as.POSIXct('2020-05-24 08:00:00', tz = "EST") & long_traffic$datetime_EST < as.POSIXct('2020-05-26 11:00:00', tz = "EST"), 'vehicle_avg'] <-NA # all 60s

###########
# visualizing time series
trun = long_traffic[long_traffic$camera_name == 'CAM02009CCTV7',] 
plot(trun$datetime_EST, trun$vehicle_avg, type = 'l')
range(long_traffic$datetime_EST)

############
sum(is.na(long_traffic$vehicle_avg))
long_traffic = long_traffic[!(is.na(long_traffic$vehicle_avg)),]

camera_data = read.csv("raw_data/camera_IDs_locations.csv", header = TRUE)
camera_data$camera_name = gsub(".jpg","",camera_data$ID)
camera_data_trun = camera_data[,c('camera_name','road_connect','lanes')]

long_traffic_full = merge(long_traffic, camera_data_trun, by.x = 'camera_name', by.y = 'camera_name')

write.csv(long_traffic_full, "output/vehicle_avg_per_hour_cleaned.csv", row.names = FALSE)
