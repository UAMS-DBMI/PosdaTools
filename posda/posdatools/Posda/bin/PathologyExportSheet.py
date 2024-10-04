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

def createFileList(name,myFiles,user):
    #create an activity with specified name


def getOnlyXFiles(file_type, import_id):
       str = "/getXfiles/{}/{}".format(import_id,file_type)
       return call_api(str, 0)

def main(pargs):
        background1 = BackgroundProcess(pargs.background_id, pargs.notify,pargs.activity_id)
        background1.daemonize()
        background1.print_to_email('Subprocess called: {}}'.format('PASS'))
        background1.finish()



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Creates csv for export")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
