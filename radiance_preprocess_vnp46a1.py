"""
-------------------------------------------------------------------------------
 Preprocesses NASA VNP46A1 HDF5 files. This script takes raw .h5 files and
 completes the following preprocessing tasks:

   - Extracts radiance and qualify flag bands
   - Masks radiance for fill values, clouds, sea water, and sensor problems
   - Fills masked data with NaN values
   - Creates a georeferencing transform
   - Creates export metadata
   - Exports radiance data to GeoTiff format

 The following variables must be set for the script to run:

   - 'hdf5_input_folder'
   - 'geotiff_output_folder'
-------------------------------------------------------------------------------
"""
# -------------------------ENVIRONMENT SETUP--------------------------------- #
import os
import warnings
import glob
import viirs

# Set options
warnings.simplefilter("ignore")

# -------------------------USER-DEFINED VARIABLES---------------------------- #
# Define path folder containing input VNP46A1 HDF5 files
hdf5_input_folder = os.path.join("", "", "")

# Defne path to output folder to store exported GeoTiff files
geotiff_output_folder = os.path.join("", "", "")

# -------------------------DATA PREPROCESSING-------------------------------- #
# Preprocess each HDF5 file (extract bands, mask for fill values, clouds,
# sea water, and sensor problems, fill masked values with NaN, export to
# GeoTiff)
hdf5_files = glob.glob(os.path.join(hdf5_input_folder, "*.h5"))
processed_files = 0
total_files = len(hdf5_files)
for hdf5 in hdf5_files:
    viirs.preprocess_vnp46a1(
        hdf5_path=hdf5, output_folder=geotiff_output_folder
    )
    processed_files += 1
    print(f"Preprocessed file: {processed_files} of {total_files}\n\n")

# -------------------------SCRIPT COMPLETION--------------------------------- #
print("\n")
print("-" * (18 + len(os.path.basename(__file__))))
print(f"Completed script: {os.path.basename(__file__)}")
print("-" * (18 + len(os.path.basename(__file__))))
