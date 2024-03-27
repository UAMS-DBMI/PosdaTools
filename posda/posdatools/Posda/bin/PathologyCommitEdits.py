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
from posda.main.file import insert_file


#Input of the Export Structure
#Get all the Path Files
#Get all the 'wating' edits for those files
#For each file create a copy (new location or old and move?)
#do all of its edits (to create only one edited copy)
#Once all edits are complete set the edited files to Good status....but not unedited? should REMOVE FILE be an 'edit'
#Export the file to the new location with name based on patient mapping


help = """
Input activity_id is expected from STDIN.
For all files in the activity with pathology edits,
 a new edited version of the file willl be created
"""

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

def  get_edits_for_file_id(file_id):
        str = "/find_edits/{}".format(file_id)
        return call_api(str, 0)

def completeEdit(edit_id):
        str = "/completeEdit/{}".format(edit_id)
        return call_api(str, 1)

def get_root_and_rel_path(file_id):
        str = "/find_relpath/{}".format(file_id)
        res = call_api(str, 0)
        return res[0]['root_path'],res[0]['rel_path']

def removeSlide(filepath):
    files = [filepath]
    anonymizeslide.anonymize(files);

def create_path_activity_timepoint(activity_id, user):
    str = "/create_path_activity_timepoint/{}/{}".format(activity_id,user)
    return call_api(str, 2)

def add_file_to_path_activity_timepoint(atf_id, file_id):
    str = "/add_file_to_path_activity_timepoint/{}/{}".format(atf_id, file_id)
    return call_api(str, 2)

def process(filepath):
    with Database("posda_files").cursor() as cur:
        #import the file
        newF = insert_file(filepath)
    return newF

def copy_path_file_for_editing(file_id: int,  destination_root_path: str ) -> str:
    """Copy a file (normally pathology) given by `file_id` to some destination

    destination_root_path must be writable by the server, but otherwise
    does not need to be a file_storage_root or otherwise known to Posda.

    The file will be written into a path that mirrors that of the source,
    *without* the file_storage_root path from the current location.

    Example:

    Say the input file 3482 is located at:
        /nas/ross/posda-pathology/projectA/series1/slide2.svs

    And it has a file_storage_root path of /nas/ross/posda-pathology
    And the destination_root_path given is /nas/ross/pathology-nfs/export

    The resulting output filename will be:
        /nas/ross/pathology-nfs/export/projectA/series1/slide2.svs

    """

    # Get the root_path and rel_path separately
    rpath = get_root_and_rel_path(file_id)
    print("Paths!")
    print(destination_root_path)
    root_path = rpath[0]
    rel_path = rpath[1]
    print(rel_path)
    source_file = pathlib.Path(root_path) / rel_path

    # calculate the output path (destination_root_path + rel_path)
    output_file = pathlib.Path(destination_root_path) / rel_path
    print(output_file)
    # create the output tree if necessary
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # copy the file
    shutil.copyfile(source_file, output_file)

    # return the final destination path (destination_root_path + rel_path)
    return output_file


#start***

destination_root_path = "/tmp/output" #/nas/ross/pathology-nfs/export



def main(pargs):
    background = BackgroundProcess(pargs.background_id, pargs.notify)
    background.daemonize()

    myFiles = get_files_for_activity(pargs.activity_id)
    myNewFiles = []
    totalEdits = 0
    print("myFiles:")


    for f in myFiles:
        new_destination_path = copy_path_file_for_editing(f['file_id'], destination_root_path)

        #do all of its edits
        edits = get_edits_for_file_id(f['file_id'])

        if (edits and len(edits) > 0):
            totalEdits = totalEdits + 1
            for e in edits:
               if e['edit_type'] == '1' or e['edit_type'] == '2': #seperate later?
                    print("removing slide now")
                    removeSlide(new_destination_path)
                    print("Completed an edit on {}".format(f['file_id']))
                    completeEdit(e['pathology_edit_queue_id'])

               print("Completed {} edit on file {}".format(len(edits), f['file_id']))
               new_file_id = process(new_destination_path)
               myNewFiles.append(new_file_id)
               print("File {} should  now be file {}".format(f['file_id']), new_file_id)

        else:
            print("No edits found for file {}".format(f['file_id']))
            myNewFiles.append(f['file_id'])
        print ('Edits {}'.format(edits))
    if (totalEdits > 0):
        get_atp = create_path_activity_timepoint(pargs.activity_id, pargs.notify)
        new_atp = get_atp[0]['activity_timepoint_id']
        print("My new TP is {}".format(new_atp))
        for n in myNewFiles:
           print('adding file to tp')
           print("My file to insert is {}".format(n))
           add_file_to_path_activity_timepoint(new_atp, n)
        print("Completed edits on activity {}. TP should now be ".format(pargs.activity_id),new_atp)
    else:
        print("No waiting edits exist for activity {}.".format(pargs.activity_id))
    background.finish()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Takes an Activity and creates the thumbnails for review for the SVS files")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
