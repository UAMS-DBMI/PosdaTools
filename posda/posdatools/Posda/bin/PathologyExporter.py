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

def export_file(path,collectionname,studyid,clinicaltrialsubjectid,imageid,microns_per_pixel_x,microns_per_pixel_y,bounds_x,bounds_y,bounds_w,bounds_h,vendor ):
        str = "/importPathDB/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}/{}".format(path,collectionname,studyid,clinicaltrialsubjectid,imageid,microns_per_pixel_x,microns_per_pixel_y,bounds_x,bounds_y,bounds_w,bounds_h,vendor )
        print(str)
        #return call_api(str, 0)

def main(pargs,records):
    background = BackgroundProcess(pargs.background_id, pargs.notify, pargs.activity_id)
    background.daemonize()

    for r in records:
        myImage = OpenSlide(path)
        microns_per_pixel_x = myImage.PROPERTY_NAME_MPP_X
        microns_per_pixel_y = myImage.PROPERTY_NAME_MPP_Y
        bounds_x = myImage.PROPERTY_NAME_BOUNDS_X
        bounds_y = myImage.PROPERTY_NAME_BOUNDS_Y
        bounds_w = myImage.PROPERTY_NAME_BOUNDS_WIDTH
        bounds_h = myImage.PROPERTY_NAME_BOUNDS_HEIGHT
        vendor   = myImage.PROPERTY_NAME_VENDOR
        export_file(r['path'],r['collectionname'],r['studyid'],r['clinicaltrialsubjectid'],r['imageid'],microns_per_pixel_x,microns_per_pixel_y,bounds_x,bounds_y,bounds_w,bounds_h,vendor )


    print("Pathology export complete.")
    background.finish("Complete")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyExporter")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")

    for line in sys.stdin:
        patient_id, original_file_name, collection_name, site_name, study_id, image_id, clinical_trial_subject_id = (line.rstrip()).split('&')
        mappingData = {}
        mappingData['path'] = path
        mappingData['collectionname'] = collectionname
        mappingData['studyid'] = studyid
        mappingData['clinicaltrialsubjectid'] = clinicaltrialsubjectid
        mappingData['imageid'] = imageid
        records.append(mappingData)

    args = parser.parse_args()
    main(args,records)
