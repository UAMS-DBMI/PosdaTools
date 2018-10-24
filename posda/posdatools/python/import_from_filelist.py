#!/usr/bin/python3.6 -u

import csv
import sys
import json
import os
from pathlib import Path
import shutil
import tempfile
import subprocess

import pydicom

from posda.queries import Query
from posda.main import args
from posda.util import md5sum

# from collections import namedtuple, defaultdict

help = """
Consume a posda filelist (plist) file and import all listed files into Posda.
"""

parser = args.Parser(
    arguments=[
               args.CustomArgument("plist", 
                                   "The Posda Filelist (plist) file to read"),
              ],
    purpose="Import plist into posda",
    help=help)
pargs = parser.parse()


# Preload queries that will be used in functions, so they aren't loaded repeatedly
get_posda_file_id_by_digest = Query("GetPosdaFileIdByDigest")
insert_file_posda = Query("InsertFilePosda")
get_current_posda_file_id = Query("GetCurrentPosdaFileId")
insert_file_import_long = Query("InsertFileImportLong")
make_posda_file_ready_to_process = Query("MakePosdaFileReadyToProcess")
insert_file_location = Query("InsertFileLocation")



def make_rel_path_from_digest(digest):
    return Path() / digest[:2] / digest[2:4] / digest[4:6] / digest


def get_xfer_syntax(filename):
    try:
        ds = pydicom.dcmread(filename)
        return ds.file_meta.TransferSyntaxUID
    except:
        return None

def fix_xfer_syntax(filename):
    """Convert the xfer syntax of the file, if needed

    Test the xfer syntax of this file; if pixels are not raw,
    we need to convert it to raw. The converted file
    is stored in a temporary location.

    
    Returns: (filename, original_filename)
    If conversion was necessary, filename will contain the new filename,
    and original_filename will contain the original filename, prefixed
    with "decompressed;". Example: "decompressed;/mnt/temp/files/some_file.dcm"


    If no conversion was done, both filename and original_filename will
    be equivalent.
    """

    current_syntax = get_xfer_syntax(filename)
    if current_syntax == '1.2.840.10008.1.2.1' or current_syntax is None:
        return (filename, filename)
    else:
        print(current_syntax)

    new_filename = tempfile.mktemp(prefix='iffpy')

    subprocess.run(["gdcmconv",
                    "-w",
                    "-i", filename,
                    "-o", new_filename])

    print(f"Successfully converted file: {new_filename}")

    return (new_filename, f"decompressed;{filename}")

def import_one_file(import_event_id, root, line_obj):
    root_id, root_path = root

    file, original_file = fix_xfer_syntax(line_obj['filename'])
    size = line_obj['size']

    # get digest of the file
    digest = md5sum(file)

    file_id = get_posda_file_id_by_digest.get_single_value(digest)

    exists = False

    if file_id is not None:
        print("File exists: ", file_id)
        exists = True

    else:
        insert_file_posda.execute(
            digest=digest,
            size=size
        )

        file_id = get_current_posda_file_id.get_single_value()

    insert_file_import_long.execute(
        import_event_id=import_event_id,
        file_id=file_id,
        rel_path=None,
        rel_dir=None,
        file_name=original_file,
    )

    # TODO: refactor this, it is so ugly!
    if not exists:

        rel_path = copy_file(file_id, digest, root_id, root_path, file)

        # set the file location
        insert_file_location.execute(
            file_id=file_id,
            file_storage_root_id=root_id,
            rel_path=str(rel_path)
        )

        # mark ready to process
        make_posda_file_ready_to_process.execute(file_id)

    if original_file.startswith('decompressed;'):
        os.unlink(file)


def copy_file(file_id, digest, root_id, root_path, source_path):
    rel_path = make_rel_path_from_digest(digest)
    destination_path = root_path / rel_path

    # Ensure the parent dir exists
    destination_path.parent.mkdir(parents=True, exist_ok=True)

    print(source_path, destination_path)
    shutil.copy(source_path, destination_path)

    return rel_path

filename = pargs.plist

# Begin an import event
Query("InsertEditImportEvent").execute(
    import_type="plist import",
    import_comment="test comment",
)

import_event_id = Query("GetImportEventId").get_single_value()
for row in Query("GetPosdaFileCreationRoot").run():
    root = tuple(row)

print(root)

# Each line of a plist should be a json-encoded dictionary
with open(filename) as infile:
    for line in infile:
        obj = json.loads(line)
        import_one_file(import_event_id, root, obj)
        # break
