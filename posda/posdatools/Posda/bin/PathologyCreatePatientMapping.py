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
        str = "/find_relpath/{}".format(file_id)
        return call_api(str, 0)

def  set_mapping(file_id,patient_id,collection_name,site_name,study_name,image_id,clinical_trial_subject_id):
        str = "/setmapping/{}/{}/{}/{}/{}/{}/{}".format(file_id,patient_id,collection_name,site_name,study_name,image_id,clinical_trial_subject_id)
        return call_api(str, 2)

def main(pargs,records,filenames):
# needs to respect new import process
# needs to include the features necessary for Export
# should repeated values be in their own table?
# repeated:  collectionname, studyid
# unique: clinicaltrialsubjectid,imageid, patient_id???

    background = BackgroundProcess(pargs.background_id, pargs.notify, pargs.activity_id)
    background.daemonize()

    count = 0
    myFiles = get_files_for_activity(args.activity_id)

    #print('Records: {}'.format(records))
    #print('Names: {}'.format(filenames))
    #print('Files: {}'.format(myFiles))
    for f in myFiles:
        p = get_relpath(f['file_id'])[0]
        my_path = str(p['rel_path'])
        my_path = my_path.replace('inplace/', '').replace('/tmp/output', '')
        #print('File {} has path {}'.format(f, my_path))
        if my_path in filenames:
            count += 1
            j = filenames.index(my_path)
            rec = records[j]
            try:
                set_mapping(f['file_id'], rec['patient_id'], rec['collection_name'], rec['site_name'],  rec['study_id'], rec['image_id'], rec['clinical_trial_subject_id'])
                print("Mapping created for {}".format(rec['patient_id']));
            except  Exception as e:
                print('Error! Mapping found but not set! {} : {}'.format(f['file_id'],e))
        else:
            print("Mapping record {} not found in activity".format(my_path));


    print("Pathology patient mapping created.\n{0} files mapped out of {1} files in mapping.\nActivity total files {2}.\n".format(
    count, len(filenames), len(myFiles)))
    background.finish("Complete")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyCreatePatientMapping")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")

    # parser.add_argument("patient_id")
    # parser.add_argument("original_file_name")
    # parser.add_argument("collection_name")
    # parser.add_argument("site_name")
    # parser.add_argument("image_id")
    # parser.add_argument("study_id")
    # parser.add_argument("clinical_trial_subject_id")

    #get the STDIN data
    records = []
    filenames = []


    for line in sys.stdin:
        patient_id, original_file_name, collection_name, site_name, study_id, image_id, clinical_trial_subject_id = (line.rstrip()).split('&')
        mappingData = {}
        mappingData['patient_id'] = patient_id
        mappingData['original_file_name'] = original_file_name
        mappingData['collection_name'] = collection_name
        mappingData['site_name'] = site_name
        mappingData['study_id'] = study_id
        mappingData['image_id'] = image_id
        mappingData['clinical_trial_subject_id'] = clinical_trial_subject_id
        records.append(mappingData)
        filenames.append(original_file_name)

    args = parser.parse_args()
    main(args,records,filenames)
