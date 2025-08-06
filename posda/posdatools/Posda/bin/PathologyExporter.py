#!/usr/bin/env python3

import argparse
import csv
import sys
import os
import requests
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.config import Config
from openslide import OpenSlide

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
            res = response.json()
            return res
        except ValueError as e:  # Catch JSON decoding errors
            print(f"Error decoding JSON from response: {e}")
            return None  # or {}, [] based on expected data type
    else:
        print(f"Error fetching data. Status code: {response.status_code}, Response: {response.text}")
        return None  # or {}, [] based on expected data type

def export_file(path, collectionname, studyid, clinicaltrialsubjectid, imageid ,reference_pixel_physical_value_x,reference_pixel_physical_value_y,image_volume_width, image_volume_height):
        str = "/importPathDB/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}".format(path,collectionname,studyid,clinicaltrialsubjectid,imageid,microns_per_pixel_x,microns_per_pixel_y,bounds_x,bounds_y,bounds_w,bounds_h,vendor )
        print(str)


def main(pargs,records):
    background = BackgroundProcess(pargs.background_id, pargs.notify, pargs.activity_id)
    background.daemonize()

    for r in records:
        print(r['path'])
        try:
            myImage = OpenSlide(r['path'])
            dims = myImage.dimensions()
            image_volume_width = float(dims[0])
            image_volume_height =  float(dims[1])
            reference_pixel_physical_value_x = 0
            reference_pixel_physical_value_y = 0
            if myImage.properties['openslide.mpp-x'] and myImage.properties['openslide.mpp-y']:
                reference_pixel_physical_value_x = myImage.properties['openslide.mpp-x']
                reference_pixel_physical_value_y = myImage.properties['openslide.mpp-y']
            else: #calculate
                area = (image_volume_width) * (image_volume_height)
                if area > 0: #TODO fix this
                    reference_pixel_physical_value_x = 10000 / area
                    reference_pixel_physical_value_y = 10000 / area
            export_file(r['path'],r['collectionname'],r['studyid'],r['clinicaltrialsubjectid'],r['imageid'],reference_pixel_physical_value_x,reference_pixel_physical_value_y,image_volume_width, image_volume_height)
        except Exception as e:
            print(f"Error decoding ImageFile: {e}")

    print("Pathology export complete.")
    background.finish("Complete")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyExporter")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    records = []
    for line in sys.stdin:
        root, path, collectionname, studyid, clinicaltrialsubjectid, imageid = (line.rstrip()).split('&')
        mappingData = {}
        mappingData['path'] = os.path.join(root, path)
        mappingData['collectionname'] = collectionname
        mappingData['studyid'] = studyid
        mappingData['clinicaltrialsubjectid'] = clinicaltrialsubjectid
        mappingData['imageid'] = imageid
        records.append(mappingData)

    args = parser.parse_args()
    main(args,records)
