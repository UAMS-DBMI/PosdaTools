#!/usr/bin/env python3

import os
import sys
import csv
import argparse
import pydicom

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

def get_linked_file_info(SOPInst,SOPClass):
    str = "/".format(file_id)
    return call_api(str, 0)

def find_path(file_id):
    str = "/".format(file_id)
    return call_api(str, 0)

def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    myFiles = find_segs_in_activity(args.activity_id);
    for f in myFiles:
        path = find_path(f['file_id'])
        ds = pydicom.dcmread(path)
        if hasattr(ds, "ReferencedSeriesSequence"):
            referenced_series = ds.ReferencedSeriesSequence[0]
             if hasattr(referenced_series, "ReferencedInstanceSequence"):
                 referenced_instances = referenced_series.ReferencedInstanceSequence
                 for instance in referenced_instances:
                     #find the corresponding file and get its file_id
                     linked_file = get_linked_file_info(instance.ReferencedSOPInstanceUID, instance.ReferencedSOPClassUID)
                     populate_seg_linkages(linked_file, f['file_id'], instance.ReferencedSOPInstanceUID, instance.ReferencedSOPClassUID):


    background.finish(f"Process complete")


def parse_args():
    parser = argparse.ArgumentParser(description=about)
    parser.add_argument('background_id', nargs='?', default='', help='the background_subprocess_id (blank for CL Mode)')
    parser.add_argument('activity_id', help='the activity seg files are in')
    parser.add_argument('notify', help='user to notify when complete')
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
