# Code to import, truncate, and add modifiers to 
# aggregate cases from PA

# source functions
source('radiance_functions.R')
# read in full dataframe
pa_data = read.csv('raw_data/COVID-19_Aggregate_Cases_Current_Daily_County_Health_dwn_20201217.csv', header = TRUE)

pa_data$Date = as.Date(pa_data$Date, format = '%m/%d/%Y')
pa_data$Date_adj = pa_data$Date - 14
pa_data$phase = getphase(pa_data$Date)
pa_data$phase2 = getphase(pa_data$Date_adj)
pa_data = pa_data[pa_data$Date < as.Date('2020-08-26'),]


central_counties = c('Blair', 'Centre', 'Clearfield', 'Clinton', 'Huntingdon', 'Mifflin', 'Union')

pa_data_central = pa_data[pa_data$Jurisdiction %in% central_counties,]
pa_data_centre = pa_data[pa_data$Jurisdiction == 'Centre',]


write.csv(pa_data_central, 'output/pa_central_20210301.csv')
write.csv(pa_data_centre, 'output/pa_centre_20210301.csv')
