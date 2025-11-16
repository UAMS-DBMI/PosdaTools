#!/usr/bin/env python3

import argparse
import csv
import sys
import os
import httpx
import json
import requests
import pathlib
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.config import Config
from openslide import OpenSlide

def get_files_for_activity(activity_id):
        str = "/find_files/{}".format(activity_id)
        return call_api(str, 0)

def get_root_and_rel_path(file_id):
        str = "/find_relpath/{}".format(file_id)
        res = call_api(str, 0)
        return res[0]['root_path'],res[0]['rel_path']

def insert_image_meta(file_id,format,modality,protocol,manufacturer,model,xResolution,yResolution,resolutionUnit,magnification,mppx,mppy,image_volume_width,image_volume_height,reference_pixel_physical_value_x,reference_pixel_physical_value_y):
    str = "/insert_image_meta/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}".format(file_id,format,modality,protocol,manufacturer,model,xResolution,yResolution,resolutionUnit,magnification,mppx,mppy,image_volume_width,image_volume_height,reference_pixel_physical_value_x,reference_pixel_physical_value_y)
    return call_api(str, 2)

def  call_api(unique_url, call_type):
    base_url = '{}/v1/pathology'.format(Config.get('internal-api-url'))
    #base_url = '{}/v1/pathology'.format(POSDA_INTERNAL_API_URL)
    API_KEY = Config.get('api_system_token')
    HEADERS = {'Authorization': f'Bearer {API_KEY}'}
    url = "{}{}".format(base_url,unique_url)
    if call_type == 0:
        response = requests.get(url,headers=HEADERS)
    elif call_type == 1:
        response = requests.patch(url,headers=HEADERS)
    elif call_type == 2:
        response = requests.put(url,headers=HEADERS)

        # Check if the response status code indicates success
    if response.ok:
        try:
            reso = response.json()
            return reso
        except ValueError as e:  # Catch JSON decoding errors
            print(f"Error decoding JSON from response: {e}")
            return None  # or {}, [] based on expected data type
    else:
        print(f"Error fetching data. Status code: {response.status_code}, Response: {response.text}")
        return None  # or {}, [] based on expected data type


def main(pargs,):

    background = BackgroundProcess(pargs.background_id, pargs.notify, pargs.activity_id)
    background.daemonize()

    totalSuccess = 0
    failures = 0

    files = get_files_for_activity(pargs.activity_id)
    for f in files:
        successful = False
        try:
            # get all the data.
            rpath = get_root_and_rel_path(f["file_id"])
            root_path = rpath[0]
            rel_path = rpath[1]
            mypath = mypath = str(pathlib.Path(root_path) / rel_path)
            myImage = OpenSlide(mypath)
            prop = myImage.properties
            dims = myImage.dimensions
            image_volume_width = float(dims[0])
            image_volume_height =  float(dims[1])
            reference_pixel_physical_value_x = 0
            reference_pixel_physical_value_y = 0
            mppx = 0
            mppy = 0
            res_unit = prop.get("tiff.ResolutionUnit")  # 2 = inch, 3 = cm
            xres = str(prop.get("tiff.XResolution"))
            if "/" in xres:
                numx, denx = s.split("/", 1)
                xres = str(float(numx) / float(denx))
            yres = str(prop.get("tiff.YResolution"))
            if "/" in yres:
                numy, deny = s.split("/", 1)
                yres = str(float(numy) / float(deny))
            if prop.get("openslide.mpp-x", 0) and prop.get("openslide.mpp-y", 0):
                reference_pixel_physical_value_x = float(prop.get("openslide.mpp-x", 0))
                reference_pixel_physical_value_y = float(prop.get("openslide.mpp-y", 0))
            else: #calculate
                divisor = 10000.0 #cm default
                if res_unit:
                    if res_unit == "inch":
                        divisor = 25400.0
                if xres and yres:
                    reference_pixel_physical_value_x = divisor / (float(xres.split('/')[0]) / float(xres.split('/')[1]))
                    reference_pixel_physical_value_y = divisor / (float(yres.split('/')[0]) / float(yres.split('/')[1]))
            mppx = reference_pixel_physical_value_x
            mppy = reference_pixel_physical_value_y
            #cropped_path = str(r['path']).replace('/nas/ross/','')
            format = prop.get("openslide.format", 0)
            modality = prop.get("openslide.modality", 0)
            protocol = prop.get("openslide.protocol", 0)
            manufacturer = prop.get("openslide.manufacturer", 0)
            model = prop.get("openslide.model", 0)
            magnification  = prop.get("openslide.magnification", 0)
            #insert the data
            successful = insert_image_meta(f['file_id'],format,modality,protocol,manufacturer,model,xres,yres,res_unit,magnification,mppx,mppy,image_volume_width,image_volume_height,reference_pixel_physical_value_x,reference_pixel_physical_value_y)
        except Exception as e:
            print(f"Error: {e}")
        if successful:
            totalSuccess=totalSuccess+1
        else:
            failures=failures+1

    print("Pathology images metadata saved. {} files have saved successfully. {} failures.".format(totalSuccess,failures))
    background.finish("Complete")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyExporter")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")

    args = parser.parse_args()
    main(args)
