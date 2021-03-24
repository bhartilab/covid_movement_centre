Code for models and figures for manuscript on quantifying movement and its impact on COVID-19 transmission in Centre County, PA, USA

Data are all from open access sources:
1. Traffic camera still images captured in real-time:
2. SafeGraph mobile phone location data:
    downloaded on XYZ. truncated to Points of Interest in census blocks for Centre County
3. Radiance data (VNP)
    downloaded on XYZ. 
4. COVID-19 case reports, Pennsylvania Department of Health:
  https://data.pa.gov/Health/COVID-19-Aggregate-Cases-Current-Daily-County-Heal/j72v-r42c
  aggregated case data used in this analysis downloaded on December 17, 2020
  
Code in this repository provides details on workflow for processing raw data and analyzing time series of different data sets:
Traffic analyses:
1.**[filename]**: classification of traffic camera stills
2.**vehicle_cleaning.R**: cleaning of hourly count data for traffic cameras - namely removing frozen image counts.
3.**vehicle_predictions.R**: fitting GAMs to observed data and using to predict missing counts.
4.**vehicle_viz.R**: vizualizations for vehicle data; plots for main text and SI
SafeGraph analyses:
1.**[filename]**: identifying and truncating dataset for Centre County
2.**safegraph_cleaning.R**: adjusting mobile phone counts to match policy 'weeks' (Friday to Thursday) and normalization
3.**safegraph_analysis.R**: time series analysis of three years data
Radiance analyses:
1.**[filename]**: processing of H5D5 files to GeoTiffs with 'confident clear' pixels only
2.**radiance_analysis.R**: cropping and removing full moon days, daily means, and summaries for each phase and year 
COVID-19 case analyses:
1.**covid19_cleaning.R**: truncating data to counties of interest and time period
2.**covid19_analysis.R**: visualizing epidemic curves for region and analysis for cross-correlation with movement data
  
