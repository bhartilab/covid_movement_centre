"""
-------------------------------------------------------------------------------
After having run the ruby script 'extract_weekly_visits_and_devices_residing.rb'
This script will consume the extracted data and produce weekly time series of 
the required fields in the raw SafeGraph data.

The file 'safegraph_weekly_visits_centre_county.csv' will contain weekly visits
and vistors to all Centre County points of interest tracked by SafeGraph, and
will be assembled from files of the format '*-centre-cbg.csv' which will need
to exist in the directory in which this script is executed.

The file 'safegraph_weekly_devices_residing_centre_county.csv' will contain 
weekly sums of all devices tracked by SafeGraph which were observed to have a 
primary nighttime location residing within Centre County. This file will be 
assembled from files of the format '*-centre-cbg-home_panel_summary.csv' which
will need to exist in the directory in which this script is executed.
-------------------------------------------------------------------------------
"""

import pandas as pd
import glob



# Create DataFrame from SafeGraph weekly visit data for Centre County, PA:
safegraph_centre_county_visits_weeks = glob.glob(f"*-centre-cbg.csv")
safegraph_centre_county_visits_weeks.sort()

visits_dict = {'start_date':[], 
        'raw_visit_counts':[], 
        'raw_visitor_counts':[] 
       } 
  

visits_df = pd.DataFrame(visits_dict) 
for f in safegraph_centre_county_visits_weeks:
        c = pd.read_csv(f,names=["placekey","safegraph_place_id",
            "parent_placekey","parent_safegraph_place_id","location_name",
            "street_address","city","region","postal_code","iso_country_code",
            "safegraph_brand_ids","brands","date_range_start","date_range_end",
            "raw_visit_counts","raw_visitor_counts","visits_by_day",
            "visits_by_each_hour","poi_cbg","visitor_home_cbgs",
            "visitor_daytime_cbgs","visitor_country_of_origin",
            "distance_from_home","median_dwell","bucketed_dwell_times",
            "related_same_day_brand","related_same_week_brand","device_type"
])
        if(len(c)>0):
            visits_df.loc[len(visits_df.index)] = [c.date_range_start[0],
                    sum(c.raw_visit_counts),
                    sum(c.raw_visitor_counts)]  
    

    
visits_df['start_date']= pd.to_datetime(visits_df['start_date'])
visits_df.set_index('start_date', inplace=True)      
visits_df.sort_index(inplace=True)
visits_df.to_csv(f"safegraph_weekly_visits_centre_county.csv")    



# Create DataFrame from SafeGraph weekly devices residing count data for Centre County, PA:
safegraph_centre_county_home_panel_weeks = glob.glob(f"*-centre-cbg-home_panel_summary.csv")
safegraph_centre_county_home_panel_weeks.sort()

dict = {'start_date':[], 
        'number_devices_residing':[]
       } 
  

devices_df = pd.DataFrame(dict) 
for f in safegraph_centre_county_home_panel_weeks:
        c = pd.read_csv(f,names=["start_date","end_date","state","cbg","devices_residing"])
        if(len(c)>0):
            devices_df.loc[len(devices_df.index)] = [c.start_date[0], sum(c.devices_residing)]  
    

    
devices_df['start_date']= pd.to_datetime(devices_df['start_date'])
devices_df.set_index('start_date', inplace=True)      
devices_df.sort_index(inplace=True)
devices_df.to_csv(f"safegraph_weekly_devices_residing_centre_county.csv")    
