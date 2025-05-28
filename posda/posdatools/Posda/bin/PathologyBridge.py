#!/usr/bin/python3 -u

import sys
import pathlib
import shutil
import requests
import argparse
import os
from posda.config import Config
from posda.main import args
from posda.background import BackgroundProcess


help = """
Proof of concept ofr pathdb communication bridge
"""

def  call_internal_api(unique_url, call_type):
    base_url = '{}/v1/pathology'.format(Config.get('internal-api-url'))
    #base_url = '{}/v1/pathology'.format(POSDA_INTERNAL_API_URL)
    API_KEY = Config.get('api_system_token')
    HEADERS = {'Authorization': f'Bearer {API_KEY}'}
    url = "{}{}".format(base_url,unique_url)
    print("working on {} type {}".format(unique_url,call_type))
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

def  call_external_api(collection_name, call_type):
    url = 'https://pathdb.cancerimagingarchive.net/idmap/{}'.format(collection_name)
    #base_url = /idmap/{collection_name} ,
    #API_KEY = Config.get('api_system_token')
    #HEADERS = {'Authorization': f'Bearer {API_KEY}'}
    #url = "{}{}".format(base_url,unique_url)
    #print("working on {} type {}".format(unique_url,call_type))
    if call_type == 0:
        response = requests.get(url)
    elif call_type == 1:
        response = requests.patch(url)
    elif call_type == 2:
        response = requests.put(url)
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

def main(pargs):
    background = BackgroundProcess(pargs.background_id, pargs.notify)
    background.daemonize()

    res = call_external_api(pargs.collection_name,0)
    for r in res:
        background.print_to_email('PathDBID: {}  Image ID: {} '.format(r['PathDBID'], r['imageid']))
    background.finish()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Search on a Collection")
    parser.add_argument("background_id")
    parser.add_argument("collection_name")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
