import sys
from posda.database import Database
from posda.queries import Query
from posda.main import args
from posda.main import get_stdin_input
from posda.background import BackgroundProcess



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

#For each file create a copy (new location or old and move?)
#do all of its edits (to create only one edited copy)
#Once all edits are complete set the edited files to Good status....but not unedited? should REMOVE FILE be an 'edit'
#Export the file to the new location with name based on patient mapping

for f in myFiles:
    edits = get_edits_for_file_id(f.file_id)
    p = prepare_file_for_edit(f.file_id)
    for e in edits:
        if e.edit_type == 1:
            removeSlide('Macro', p)
        elif e.edit_type == 2:
            removeSlide('Layer', p)
    p.completeEdit()



background.finish()
