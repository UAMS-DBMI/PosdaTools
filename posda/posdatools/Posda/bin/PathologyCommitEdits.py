#!/usr/bin/python3 -u

import sys
import pathlib
import shutil
import requests
import argparse
import os
from posda.config import Config
from posda.database import Database
from posda.queries import Query
from posda.main import args
from posda.main import get_stdin_input
from posda.background import BackgroundProcess
from posda.anonymizeslide import anonymizeslide
from posda.main.file import insert_file_via_api_inplace


destination_root_path = os.environ.get(
    'POSDA_PATHOLOGY_OUTPUT_PATH',
    '/home/posda/cache/created/tmp/output' # default value
)

#Get all the Path Files
#For each file create a copy to the new location (require inplace import)
#Get all the 'waiting' edits for those files
#Do all of each file's edits
#Create new TP
#Put all edited files(and files that had no edits) in the new TP

help = """
Input activity_id is expected from STDIN.
For all files in the activity with pathology edits,
 a new edited version of the file willl be created, and placed in a new TP
"""

def  call_api(unique_url, call_type):
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

def editSlide(filepath,edit_type):
    files = [filepath]
    anonymizeslide.anonymize(files,edit_type)

def create_path_activity_timepoint(activity_id, user):
    str = "/create_path_activity_timepoint/{}/{}".format(activity_id,user)
    return call_api(str, 2)

def add_file_to_path_activity_timepoint(atf_id, file_id):
    str = "/add_file_to_path_activity_timepoint/{}/{}".format(atf_id, file_id)
    return call_api(str, 2)

def process(filepath):
    with Database("posda_files").cursor() as cur:
        #import the file
        newF = insert_file_via_api_inplace(filepath)
    return newF

def updateMapping(old_id, new_id):
    str = "/copymapping/{}/{}".format(old_id, new_id)
    return call_api(str, 2)


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

    root_path = rpath[0]
    rel_path = rpath[1]

    source_file = pathlib.Path(root_path) / rel_path

    # calculate the output path (destination_root_path + rel_path)
    rel_path = rel_path.replace('/tmp/output','') #prevent the destination folder from repeating into subfolders
    output_file = pathlib.Path(destination_root_path) / rel_path

    # create the output tree if necessary
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # copy the file
    shutil.copyfile(source_file, output_file)

    # return the final destination path (destination_root_path + rel_path)
    return output_file




def main(pargs):
    background = BackgroundProcess(pargs.background_id, pargs.notify,pargs.activity_id)
    background.daemonize()

    myFiles = get_files_for_activity(pargs.activity_id)
    myNewFiles = []
    totalEdits = 0



    for f in myFiles:
        new_destination_path = copy_path_file_for_editing(f['file_id'], destination_root_path)

        #do all of its edits
        edits = get_edits_for_file_id(f['file_id'])
        remove = False
        current_file_id = f['file_id']
        if (edits and len(edits) > 0):
            totalEdits = totalEdits + 1
            for e in edits:
                if e['edit_type'] == '5':
                    # Get the root_path and rel_path separately
                    rpath = get_root_and_rel_path(current_file_id)
                    root_path = rpath[0]
                    rel_path = rpath[1]
                    og_file_path = pathlib.Path(root_path) / rel_path
                    new_file = anonymizeslide.redactPixels(new_destination_path,og_file_path, e['edit_details'])
                    completeEdit(e['pathology_edit_queue_id'])
                    background.print_to_email("Completed {} edit on file {}".format(len(edits), current_file_id))
                elif e['edit_type'] != '4': #4 is remove file, just dont add to new activity
                    editSlide(new_destination_path, e['edit_type'])
                    completeEdit(e['pathology_edit_queue_id'])

                else:
                    completeEdit(e['pathology_edit_queue_id'])
                    background.print_to_email("File {} removed".format(current_file_id))
                    break
        else:
            background.print_to_email("No edits found for file {}".format(f['file_id']))
            myNewFiles.append(f['file_id'])

        new_file_id = process(new_destination_path)
        if (current_file_id != f['file_id'] )
            updateMapping(current_file_id, new_file_id)
        myNewFiles.append(new_file_id) #should only add the final id to the TP
        background.print_to_email("Completed {} edit on file.".format(len(edits)))
        background.print_to_email("File {} should  now be file {}.".format(current_file_id, new_file_id))

    if (totalEdits > 0):
        get_atp = create_path_activity_timepoint(pargs.activity_id, pargs.notify)
        new_atp = get_atp[0]['activity_timepoint_id']

        for n in myNewFiles:
           add_file_to_path_activity_timepoint(new_atp, n)
        background.print_to_email("Completed edits on activity {}. TP should now be ".format(pargs.activity_id),new_atp)
    else:
        background.print_to_email("No waiting edits exist for activity {}.".format(pargs.activity_id))
    background.finish()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Commits edits on SVS files")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
