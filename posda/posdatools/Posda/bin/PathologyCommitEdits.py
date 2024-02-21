import sys
import pathlib
import shutil
from posda.database import Database
from posda.queries import Query
from posda.main import args
from posda.main import get_stdin_input
from posda.background import BackgroundProcess
from posda.anonymize-slide import anonymize-slide



#Input of the Export Structure
#Get all the Path Files
#Get all the 'wating' edits for those files
#For each file create a copy (new location or old and move?)
#do all of its edits (to create only one edited copy)
#Once all edits are complete set the edited files to Good status....but not unedited? should REMOVE FILE be an 'edit'
#Export the file to the new location with name based on patient mapping

#!/usr/bin/python3.6 -u


help = """
Input activity_id is expected from STDIN.
For all files in the activity with pathology edits,
 a new edited version of the file willl be created
"""


def get_Files_for_activity(activity_id, db) -> int:
    query = """\
    select file_id from file f join activity_timepoint_file atf  on f.file_id = atf.file_id
        where atf.activity_timepoint_id in (
            select
                max(activity_timepoint_id) as activity_timepoint_id
            from
                activity_timepoint
            where
                activity_id = $1
          );
    """
    return await db.fetch(query, [activity_id])


def get_edits_for_file_id(file_id, db) -> int:
    query = """\
    select edit_type, edit_details from pathology_edit_queue
            where
                file_id = $1
                and status = 'waiting'
          );
    """
    return await db.fetch(query, [file_id])

def get_root_and_rel_path(file_id: int, cursor):
    cursor.execute("""\
        select root_path, rel_path
        from file_location
        natural join file_storage_root
        where file_id = %s
    """, [file_id])

    for root_path, rel_path in cursor:
        return root_path, rel_path


def removeSlide(filepath):
    files = [filepath]
    anonymize-slide.anonymize(files);


def  completeEdit(file_id):
     #for testing
     user = 'Reviewer'
     query = """\
     INSERT INTO pathology_visual_review_status
     VALUES($1 , $2, $3, now());
           );
     """
     return await db.fetch(query, [file_id, "Review", user])

def copy_path_file_for_editing(file_id: int,
                               destination_root_path: str,
                               database_cursor) -> str:
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
    root_path, rel_path = get_root_and_rel_path(file_id, database_cursor)
    source_file = pathlib.Path(root_path) / rel_path

    # calculate the output path (destination_root_path + rel_path)
    output_file = pathlib.Path(destination_root_path) / rel_path

    # create the output tree if necessary
    output_file.parent.mkdir(parents=True, exist_ok=True)

    # copy the file
    shutil.copyfile(source_file, output_file)

    # return the final destination path (destination_root_path + rel_path)
    return output_file



#start
conn = Database('posda_files')
cur = conn.cursor()
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

myFiles = get_Files_for_activity(pargs.activity_id)

new location or old and move?)
 (to create only one edited copy)



for f in myFiles{

    new_destination_path = copy_path_file_for_editing(f, destination_root_path,cur)

    #do all of its edits
    edits = get_edits_for_file_id(f.file_id,conn)

    for e in edits:
        if e.edit_type == 1 or e.edit_type == 2: #seperate later?
            removeSlide(new_destination_path)

    #Once all edits are complete set the edited files to Good? or Edited? status
    # but not unedited? should REMOVE FILE be an 'edit'

    completeEdit(f.file_id))



background.finish()
