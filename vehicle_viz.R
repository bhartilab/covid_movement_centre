############
# code to look 
############
# libraries
library(ggplot2)
library(zoo) #rolling mean
library(tidyr) # long >wide
library(dplyr)
library(RColorBrewer)
library(ggplot2)

####
# import data
hourly_predicted = read.csv("output/gam4_predicted_hourly_green_red.csv", header = TRUE)

class(hourly_predicted$phase)
hourly_predicted$phase <- factor(hourly_predicted$phase, levels = c("red", "green"))
camera_loc = read.csv("raw_data/camera_IDs_locations.csv", header = TRUE)
camera_loc$road_connect
complete_vehicle = read.csv("output/predicted_observed_camera_data.csv", header = TRUE)
complete_vehicle$date = as.Date(complete_vehicle$date)
########
# maps
pa_crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
major_roads <- readOGR('/Users/cfaust/Documents/workspace/pageocov_large_files/shapefiles/Major_Roads-shp',
                       'Major_Roads')
counties <- readOGR(dsn="/Users/cfaust/Box/pa_covid/shapefiles/Pennsylvania County Boundaries",
                    layer = 'geo_export_6e3956ed-1c8f-4533-acac-de9d05463420')
counties_wgs =  spTransform(counties,pa_crs)
centre_co = counties_wgs[counties_wgs@data$county_nam == 'CENTRE',]
major_roads_wgs = spTransform(major_roads,pa_crs)


###########
# figure 3a - maps
camera_loc_xy = camera_loc[,c('Longitude','Latitude')] #converting into a spatial dataframe
camera_loc_spdf = SpatialPointsDataFrame(coords = camera_loc_xy, data = camera_loc,
                                    proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
plot(camera_loc_spdf)
plot(centre_co,  xlim = c(-78.00, -77.74), ylim = c(40.76,41.07))
plot(major_roads_wgs, add = T, col = 'grey80')
plot(camera_loc_spdf, add = TRUE, col = cam_col, pch = 17, cex =2)
extent(camera_loc_spdf)

plot(centre_co)



#########
# figure 3b - hourly traffic

rush_hours = data.frame(x1=c(6.5,15.5), x2=c(9.5,18.5))
cameras = unique(hourly_predicted$camera_name)
#12 between; #7 between
pur_col = colorRampPalette(c("#d9830b", "#f5e3c9"))(7)
con_col = rev(colorRampPalette(c('#04347d', '#bed1ed'))(12))
cam_col = c(con_col[1:8],pur_col[1],con_col[9:10],pur_col[2:6], con_col[11:12], pur_col[7])
hourly_predicted$fit
ggplot(hourly_predicted, aes(x = hour, y = fit, col = camera_name)) +
  geom_rect(data=rush_hours, aes(NULL,NULL,xmin=x1,xmax=x2),
            ymin=0,ymax=425, colour="white", size=0.5, alpha=0.2) +
  geom_line(aes(color=camera_name)) +
  #geom_point(size = 1)+
  #scale_shape_manual(values=c(1, 17))+
  scale_color_manual(values = cam_col) +
  #geom_line(aes(hour, fit))+
  labs(y = 'predicted weekday traffic', x = 'hour of day')+
  theme_classic()+
  facet_wrap(~phase)+
  scale_x_continuous(breaks = seq(0,24, by =2)) +
  scale_y_continuous(breaks = seq(0,400, by =50)) 



################
#Figure 3C
traffic_daily_by_camera= as.data.frame(complete_vehicle %>%
                                         dplyr::group_by(date, camera_name, weekends, phase) %>%
                                         dplyr::summarise(daily_total = sum(vehicle_avg, na.rm = TRUE )))
ggplot(traffic_daily_by_camera, aes(date, daily_total, group = camera_name))+
  geom_line()

traffic_daily_by_road= as.data.frame(complete_vehicle %>%
                                       dplyr::group_by(date, road_connect, weekends, phase) %>%
                                       dplyr::summarise(daily_total = sum(vehicle_avg, na.rm = TRUE )))
traffic_mean_daily_by_road= as.data.frame(traffic_daily_by_road %>%
                                            dplyr::group_by(road_connect, weekends, phase) %>%
                                            dplyr::summarise(daily_mean = mean(daily_total, na.rm = TRUE ),
                                                             days = length(daily_total)))
write.csv(traffic_mean_daily_by_road,"output/table_mean_road_traffic_estimated_with_gam.csv", row.names = FALSE)

traffic_daily= as.data.frame(complete_vehicle %>%
                               group_by(date, weekdays, weekends, phase) %>%
                               summarise(daily_total = sum(vehicle_avg, na.rm = TRUE)))

traffic_daily= as.data.frame(complete_vehicle %>%
                               group_by(date, weekdays, weekends, phase) %>%
                               summarise(daily_total = sum(vehicle_avg, na.rm = TRUE)))
write.csv(traffic_daily, "output/daily_traffic_estimates.csv", row.names = FALSE)

traffic_daily_phase = as.data.frame(traffic_daily %>%
                                      group_by(weekends, phase) %>%
                                      summarise(daily_avg = mean(daily_total, na.rm = TRUE),
                                                daily_sd = sd(daily_total)))


unique_df = data.frame('unique_dates' = unique(complete_vehicle$date))
unique_df$phase = cut(unique_df$unique_dates,breaks = c(as.Date('2020-03-28'),as.Date('2020-05-08'),# policy red from 4/27 to 5/7
                                                              as.Date('2020-05-29'),#  yellow 5/8 to 5/28
                                                              as.Date('2020-07-06')), #  green 5/29 to 6/29
                             labels=c("red","yellow","green"))
class(unique_df$unique_dates)
unique_df$weekdays = weekdays(unique_df$unique_dates)
unique_df$weekends = unique_df$weekdays %in% c("Sunday", "Saturday")
sum = as.data.frame(unique_df %>%
                    group_by(weekends,phase) %>%
                    dplyr::summarise(total_days = length(unique_dates)))


pd <- position_dodge(0.5)
ggplot(traffic_daily_phase, aes(x=phase, y=daily_avg, colour=phase, group=weekends)) + 
  geom_errorbar(aes(ymin=daily_avg-daily_sd, ymax=daily_avg+daily_sd), colour="black", width=0, position=pd) +
  geom_point(aes(shape = factor(weekends)),position=pd, size= sqrt(sum$total_days)*2)+
  scale_shape_manual(values=c(20,18)) + 
  scale_color_manual(values=c("darkred", "darkgoldenrod", "forestgreen")) +
  theme_classic(base_size = 14) +
  scale_y_continuous(breaks = seq(0,30000, by =5000), 
                     limits = c(0, 30000), expand = c(0, 0))+
  labs(y = "average total daily traffic", x = "restriction phase") 

##########
camera_data_pred_obs =read_csv("output/predicted_observed_camera_data.csv")
camera_data_pred_obs$phase = as.factor(camera_data_pred_obs$phase)
camera_data_pred_obs$phase = factor(camera_data_pred_obs$phase,
                                    levels = c('red','yellow','green'))
head(camera_data_pred_obs)
ggplot(camera_data_pred_obs, aes(x=datetime_EST, y=vehicle_avg, group=camera_name)) +
  geom_line(aes(color=camera_name))+
  geom_point(aes(fill=obs_type), size =0.5, pch = 21, stroke =0.1)+
  scale_fill_manual(values=c('black','white'))+
  facet_wrap(~camera_name, ncol = 1, scales="free")+
  geom_vline(xintercept=as.POSIXct('2020-04-26 20:00:00', tz = "EST"), col = '#a00707', lty = 'dotdash') +
  geom_vline(xintercept=as.POSIXct('2020-05-08 01:00:00', tz = "EST"), col = '#ecae20', lty = 'dotdash') +
  geom_vline(xintercept=as.POSIXct('2020-05-29 01:00:00', tz = "EST"), col = '#c3dfa1', lty = 'dotdash') +
  theme_classic()+
  scale_color_manual(values = cam_col) +
  theme(strip.background = element_blank(),
        strip.text.x =element_blank())+ #format="%B %d %Y"
  labs(x = "timepoint (hourly)", y = "estimated hourly vehicles")

