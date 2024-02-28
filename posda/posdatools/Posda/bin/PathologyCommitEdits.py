#!/usr/bin/python3 -u

import sys
import pathlib
import shutil
import requests
from posda.config import Config
from posda.database import Database
from posda.queries import Query
from posda.main import args
from posda.main import get_stdin_input
from posda.background import BackgroundProcess
from posda.anonymizeslide import anonymizeslide



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

def  call_api(unique_url):
    base_url = '{}/v1/pathology'.format(Config.get('internal-api-url'))
    #base_url = '{}/v1/pathology'.format(POSDA_INTERNAL_API_URL)
    API_KEY = Config.get('api_system_token')
    HEADERS = {'Authorization': f'Bearer {API_KEY}'}
    url = "{}{}".format(base_url,unique_url)
    print(url)
    response = requests.get(url,headers=HEADERS)
    print(response)
        # Check if the response status code indicates success
    if response.ok:
        try:
            res = response.json()
            print(res)
            return res
        except ValueError as e:  # Catch JSON decoding errors
            print(f"Error decoding JSON from response: {e}")
            return None  # or {}, [] based on expected data type
    else:
        print(f"Error fetching data. Status code: {response.status_code}, Response: {response.text}")
        return None  # or {}, [] based on expected data type

def get_files_for_activity(activity_id):
        str = "/find_files/{}".format(activity_id)
        return call_api(str)

def  get_edits_for_file_id(file_id):
        str = "/find_edits/{}".format(file_id)
        return call_api(str)

def completeEdit(pathid):
        str = "/completeEdit/{}".format(pathid)
        return call_api(str)

def get_root_and_rel_path(file_id):
        str = "/find_relpath/{}".format(file_id)
        res = call_api(str)
        return res[0]['root_path'],res[0]['rel_path']

def removeSlide(filepath):
    files = [filepath]
    anonymizeslide.anonymize(files);



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
    output_file = pathlib.Path(destination_root_path) / rel_path

    # create the output tree if necessary
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # copy the file
    shutil.copyfile(source_file, output_file)

    # return the final destination path (destination_root_path + rel_path)
    return output_file




#start***

destination_root_path = "/tmp/output" #/nas/ross/pathology-nfs/export



parser = args.Parser(
    arguments=[args.Presets.background_id,
               args.CustomArgument("activity_id",
                                   "The activity to edit"),
               args.Presets.notify],
    purpose="Commit edits and creates edited pathology export files",
    help=help)
pargs = parser.parse()

background = BackgroundProcess(pargs.background_id, pargs.notify)

myFiles = get_files_for_activity(pargs.activity_id)
print("myFiles:")
print (myFiles)

for f in myFiles:
    print("F in myFiles:")
    print(f)
    new_destination_path = copy_path_file_for_editing(f['file_id'], destination_root_path)

    #do all of its edits
    edits = get_edits_for_file_id(f['file_id'])

    for e in edits:
        if e.edit_type == 1 or e.edit_type == 2: #seperate later?
            removeSlide(new_destination_path)

    #Once all edits are complete set the edited files to Good? or Edited? status
    # but not unedited? should REMOVE FILE be an 'edit'

    completeEdit(f['file_id'])



background.finish()
