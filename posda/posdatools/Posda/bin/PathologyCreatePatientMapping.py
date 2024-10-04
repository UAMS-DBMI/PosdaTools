#!/usr/bin/env python3

import argparse
import csv
import sys
import os


from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess


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

def get_files_for_activity(activity_id):
        str = "/find_files/{}".format(activity_id)
        return call_api(str, 0)

def get_relpath(file_id):
        str = "/find_relpath/{}".format(activity_id)
        return call_api(str, 0)

def  set_mapping(file_id,patient_id,original_file_name,collection_name,site_name,study_name,image_id,clinical_trial_subject_id):
        str = "/setmapping/{}/{}/{}/{}/{}/{}/{}/{}/{}".format(file_id,patient_id,original_file_name,collection_name,site_name,study_name,image_id,clinical_trial_subject_id)
        return call_api(str, 0)

def main(pargs):
# needs to respect new import process
# needs to include the features necessary for Export
# should repeated values be in their own table?
# repeated:  collectionname, studyid
# unique: clinicaltrialsubjectid,imageid, patient_id???

    background = BackgroundProcess(pargs.background_id, pargs.notify, pargs.activity_id)
    background.daemonize()

    results = []
    count = 0
    myFiles = get_files_for_activity(args.activity_id)
    for f in myFiles:
        my_path = get_relpath(f).replace('inplace/','').replace('/tmp/output','')
        print('File {} has path {}'.format(file_id,my_path))
        if my_path in pargs.original_file_name:
          count = count+1
          set_mapping(file_id,pargs.patient_id,my_path,pargs.collection_name,pargs.site_name,pargs.study_id,pargs.clinical_trial_subject_id)
    print("Patholgy patient mapping created.\n{0} files mapped out of {1} files in mapping.\nActivity total files {2}.\n".format(count, len(results)+1, len(row)+1))
    background.finish("Complete")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyCreatePatientMapping")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    parser.add_argument("patient_id")
    parser.add_argument("original_file_name")
    parser.add_argument("collection_name")
    parser.add_argument("site_name")
    parser.add_argument("image_id")
    parser.add_argument("study_id")
    parser.add_argument("clinical_trial_subject_id")
    args = parser.parse_args()

    main(args)
