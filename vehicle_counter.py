"""
-------------------------------------------------------------------------------
This script feeds images to the cvlib object detector and outputs two CSV 
files, one that consists of datetimes, filepaths, and vehicle counts, and a
second which includes in addition to the datetimes and filepaths labels for all
detected objects and their bounding boxes.

The cvlib library is available here: https://github.com/arunponnusamy/cvlib

The cvlib library uses the YOLOv3 object detection algorithm and has
dependencies on tensorflow and opencv2.

The original YOLO algorithm is documented here:
https://arxiv.org/abs/1506.02640

The YOLOv3 algorithm is documented here:
https://arxiv.org/abs/1804.02767v1

The YOLOv3 model employed was trained on the COCO dataset, available at:
https://cocodataset.org/


TODO:  Add additional documentation on staging of image files for efficient 
processing, usage of EC2 instances, GNU parallel.
-------------------------------------------------------------------------------
"""
import sys 
import glob
import os
from datetime import datetime
import cv2
import cvlib as cv
from cvlib.object_detection import draw_bbox
import pandas as pd
import csv

# Path to the set of images:
camsdir = sys.argv[1] 
# Subpath named for camera, images from which it contains:
camname = sys.argv[2] 
# Subpath named for date (YYYYMMDD) of the images it contains:
day = sys.argv[3] 
# Subpath named for hour (HH) of images it contains :
hour = sys.argv[4] 

# Note that image filenames must have the following format:
# {date}_{time}_{camname}.jpg
# For example:
# 20210322_140752_CAM02028CCTV32.jpg 

target_image_files = glob.glob(f"/home/ubuntu/{camsdir}/{camname}/{day}/{day}_{hour}*_{camname}.jpg")

file_and_datetime_list = []   
for target in target_image_files:
    t = os.path.basename(target)
    tps = t.split("_")
    ft = f"{tps[0]}_{tps[1]}"
    d = datetime.strptime(ft, '%Y%m%d_%H%M%S')
    file_and_datetime_list.append([target,d])
    
files = sorted(file_and_datetime_list, key=lambda x: x[1])    

image_vehicle_count_list = []
image_full_tag_list = []
for i in files:
    # If the file is large enough to be a viable image:
    if (os.stat(i[0]).st_size > 1000):
        im = cv2.imread(i[0])
        # If the file is otherwise unreadable:
        if(type(im) == 'NoneType'):
            print("unreadable: ",i)
        else:
            try:
                t = os.path.basename(i[0])
                tps = t.split("_")
                ft = f"{tps[0]}_{tps[1]}"
                d = datetime.strptime(ft, '%Y%m%d_%H%M%S')
                bbox, label, conf = cv.detect_common_objects(im)
                vehicle_count = 0 
                # Increment count with objects we consider vehicles
                vehicle_count += label.count('car')
                vehicle_count += label.count('truck')
                vehicle_count += label.count('bus')
                # Append tuple of datetime, imagefile, vehicle_count 
                image_vehicle_count_list.append([d,i[0],vehicle_count])
                # Records labels of all objects and their bounding boxes:
                image_full_tag_list.append([d,i[0],label,bbox])
            except:
                continue

camdf = pd.DataFrame(image_vehicle_count_list,columns = ['time','file','vehicle'])
camdf.to_csv(f"df_{camsdir}_vehicles_{day}_{hour}_{camname}.csv",index=False)

with open(f"df_{camsdir}_fulltags_{day}_{hour}_{camname}.csv","w") as f:
    wr = csv.writer(f)
    wr.writerows(image_full_tag_list)
