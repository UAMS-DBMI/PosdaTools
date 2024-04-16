#!/usr/bin/python3 -u

import sys
import pathlib
import shutil
import requests
import argparse
from posda.config import Config
from posda.database import Database
from posda.queries import Query
from posda.main import args
from posda.main import get_stdin_input
from posda.background import BackgroundProcess
from posda.anonymizeslide import anonymizeslide
from posda.main.file import insert_file_via_api_inplace


def call_api(unique_url, call_type):
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

def createActivityFromFiles(name,myFiles,user):
    #create an activity with specified name
    str = "/create_path_activity/{}/{}".format(name,user)
    get_act_id = call_api(str, 2)
    act_id = get_act_id[0]['activity_id']

    #create the intial TP with given files
    str = "/create_path_activity_timepoint/{}/{}".format(act_id,user)
    get_atp = call_api(str, 2)
    new_atp = get_atp[0]['activity_timepoint_id']
    for n in myFiles:
       file_id = n['file_id']
       str = "/add_file_to_path_activity_timepoint/{}/{}".format(new_atp, file_id)
       call_api(str, 2)
    #return
    return act_id;

def getOnlyXFiles(file_type, import_id):
       str = "/getXfiles/{}/{}".format(import_id,file_type)
       return call_api(str, 0)

def main(pargs):


    str = "/get_files_from_import/{}".format(pargs.import_id,pargs.notify)
    myFiles = call_api(str, 0)


    if pargs.file_type is None or pargs.file_type.upper() == 'ALL' or pargs.file_type == '':
        my_act_id = createActivityFromFiles(pargs.activity_name, myFiles, pargs.notify)
        background1 = BackgroundProcess(pargs.background_id, pargs.notify,my_act_id)
        background1.daemonize()
        background1.print_to_email('Activity {}:{} created'.format(my_act_id,pargs.activity_name))
        background1.finish()
    else:
        #create first activity
        act_id1 = createActivityFromFiles(pargs.activity_name, myFiles, pargs.notify)
        background1 = BackgroundProcess(pargs.background_id, pargs.notify,act_id1)
        background1.daemonize()
        background1.print_to_email('Activity {}:{} created'.format(act_id1,pargs.activity_name))
        background1.finish()
        #create special activity
        myRFiles = getOnlyXFiles(pargs.file_type, pargs.import_id)
        my_act_name = '' + pargs.activity_name +'_' + pargs.file_type
        act_id2 = createActivityFromFiles(my_act_name,myRFiles, pargs.notify)
        background2 = BackgroundProcess(pargs.background_id, pargs.notify,act_id2)
        background2.daemonize()
        background2.print_to_email('Activity {}:{} created'.format(act_id2,my_act_name))
        background2.finish()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Creates TP with files of the specified type from the specified import")
    parser.add_argument("background_id")
    parser.add_argument("activity_name")
    parser.add_argument("import_id")
    parser.add_argument("file_type")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
