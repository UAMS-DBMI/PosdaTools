#!/usr/bin/env python3

import os
import sys
import csv
import argparse
import pydicom
import requests
from posda.config import Config
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess


about="""\
This script adds segmentation linkage data to the posda database and reports to the user if any linked SOPs are missing.
"""

def  call_api(unique_url, call_type):
    base_url = '{}/v1/segs'.format(Config.get('internal-api-url'))
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

def find_segs_in_activity(activity_id):
        str = "/find_segs_in_activity/{}".format(activity_id)
        return call_api(str, 0)

def populate_seg_linkages(file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid):
        str = "/populate_seg_linkages/{}/{}/{}/{}".format(file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid)
        return call_api(str, 2)

def get_linked_file_info(sop_instance_uid):
    str = "/getLatestFileForSop/{}".format(sop_instance_uid)
    return call_api(str, 0)


def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()
    success = 0
    fail = 0
    numSEGs = 0
    mySEGFiles = find_segs_in_activity(args.activity_id)
    if (mySEGFiles):
        numSEGs = len(mySEGFiles)
        for f in mySEGFiles:
            print("\nSegmentation {} found.".format(f['file_id']))
            current = success
            ds = pydicom.dcmread(f['path'])
            try:
                if hasattr(ds, "ReferencedSeriesSequence"):
                    referenced_series = ds.ReferencedSeriesSequence[0]
                    #print("ReferencedSeriesSequence = {}".format(ds.ReferencedSeriesSequence))
                    if hasattr(referenced_series, "ReferencedInstanceSequence"):
                        referenced_instances = referenced_series.ReferencedInstanceSequence
                        #print("ReferencedInstanceSequence = {}".format(referenced_series.ReferencedInstanceSequence))
                        for instance in referenced_instances:
                            #print(" * ReferencedSOPInstanceUID = {}".format(instance.ReferencedSOPInstanceUID))
                            #print(" * ReferencedSOPClassUID = {}".format(instance.ReferencedSOPClassUID))
                            linked_file = get_linked_file_info(instance.ReferencedSOPInstanceUID)[0]['file_id']
                            print("Linked File {}, Seg File {}, SOP UID {}, SOP Class {}".format(linked_file, f['file_id'], str(instance.ReferencedSOPInstanceUID), str(instance.ReferencedSOPClassUID)))
                            populate_seg_linkages(linked_file, f['file_id'], str(instance.ReferencedSOPInstanceUID), str(instance.ReferencedSOPClassUID))
                            success = success + 1
            except Exception as e:
                print( "Linkage failed. {}".format(e))
                fail = fail + 1
            print("\n{} linkages found for this segmentation.\n".format((success - current)))
    else:
        print("No Segmentation objects found in activity.")

    if numSEGs > 0:
        print("\n{} files successfully linked to {} segmentations. {} failed linkages.".format(success, numSEGs, fail))
    background.finish("Process complete")

def parse_args():
    parser = argparse.ArgumentParser(description=about)
    parser.add_argument('background_id', nargs='?', default='', help='the background_subprocess_id (blank for CL Mode)')
    parser.add_argument('activity_id', help='the activity seg files are in')
    parser.add_argument('notify', help='user to notify when complete')
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
