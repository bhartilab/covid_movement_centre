"""
-------------------------------------------------------------------------------
 Clips preprocessed VNP46A1 GeoTiff files to a specified area of
 interest (AOI) bounding box.

 The following variables must be set for the script to run:

   - 'geotiff_input_folder'
   - 'geotiff_output_folder'
   - 'shapefile_path'
   - 'aoi_name'
-------------------------------------------------------------------------------
"""
# -------------------------ENVIRONMENT SETUP--------------------------------- #
# Import packages
import os
import warnings
import glob
import geopandas as gpd
import viirs

# Set options
warnings.simplefilter("ignore")

# -------------------------USER-DEFINED VARIABLES---------------------------- #
# Set path to folder containing preprocessed VNP46A1 files
geotiff_input_folder = os.path.join("", "", "")

# Set path to output folder to store clipped files
geotiff_output_folder = os.path.join("", "", "")

# Set path to shapefile for clipping GeoTiff files
shapefile_path = os.path.join("", "", "")

# Set AOI name (for file export name)
aoi_name = "Centre County"

# -------------------------DATA PREPROCESSING-------------------------------- #
# Clip images to bounding box and export clipped images to GeoTiff files
geotiff_files = glob.glob(os.path.join(geotiff_input_folder, "*.tif"))
clipped_files = 0
total_files = len(geotiff_files)
for file in geotiff_files:
    viirs.clip_vnp46a1(
        geotiff_path=file,
        clip_boundary=gpd.read_file(shapefile_path),
        clip_country=aoi_name,
        output_folder=geotiff_output_folder,
    )
    clipped_files += 1
    print(f"Clipped file: {clipped_files} of {total_files}\n\n")

# -------------------------SCRIPT COMPLETION--------------------------------- #
print("\n")
print("-" * (18 + len(os.path.basename(__file__))))
print(f"Completed script: {os.path.basename(__file__)}")
print("-" * (18 + len(os.path.basename(__file__))))
