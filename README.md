Code for models and figures for manuscript entitled: **Passive surveillance assesses compliance with COVID-19 behavioral restrictions in a rural US county**

Authors: Faust, Lambert, Kochenour, Robinson, Bharti

Data are all from open access sources:
1. Traffic camera still images captured in real-time from PA DOT (e.g. http://www.dot35.state.pa.us/public/Districts/District2/WebCams/CAM02005CCTV9.jpg)
2. SafeGraph mobile phone location data: [https://catalog.safegraph.io/app/browse]. Downloaded on 03/15/21.
3. COVID-19 case reports, Pennsylvania Department of Health (https://data.pa.gov/Health/COVID-19-Aggregate-Cases-Current-Daily-County-Heal/j72v-r42c).Aggregated case data used in this analysis downloaded on December 17, 2020

Code in this repository provides details on workflow for processing raw data and analyzing each dataset:

Traffic analyses:
1. **vehicle_counter.py**: classification of traffic camera stills
2. **vehicle_cleaning.R**: cleaning of hourly count data for traffic cameras - namely removing frozen image counts.
3. **vehicle_predictions.R**: fitting GAMs to observed data and using to predict missing counts.
4. **vehicle_viz.R**: vizualizations for vehicle data; plots for main text and SI

SafeGraph analyses:
1. **safegraph_extract_weekly_visits_and_devices_residing.rb**: identifying and extracting dataset for Centre County
1. **safegraph_create_centre_county_dataframes.py**: converting raw data for Centre County into time series
2. **safegraph_cleaning.R**: adjusting mobile phone counts to match policy 'weeks' (Friday to Thursday) and normalization
3. **safegraph_analysis.R**: time series analysis of three years data

COVID-19 case analyses:
1. **covid19_cleaning.R**: truncating data to counties of interest and time period
2. **covid19_analysis.R**: visualizing epidemic curves for region and analysis for cross-correlation with movement data

**Phase_functions.R**: function to assign phase based on year and academic calendar (see SI of manuscript for justification)
