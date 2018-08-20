import csv
import sys
import os
from pathlib import Path
import shutil
import tempfile
import subprocess



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
get_matching_root = Query("GetMatchingRootID")
create_new_root = Query("InsertNewRootPath")


def make_rel_path_from_digest(digest):
    return Path() / digest[:2] / digest[2:4] / digest[4:6] / digest


# def get_xfer_syntax(filename):
#     try:
#         ds = pydicom.dcmread(filename)
#         return ds.file_meta.TransferSyntaxUID
#     except:
#         return None

def import_one_file(import_event_id, root_id, line_obj):

    root_path = line_obj[0]
    file = line_obj[1]
    size = line_obj[2]
    test_digest = line_obj[3]

    print ("Data was read: ",root_path,  file, size)

    # get digest of the file
    digest = md5sum(root_path + "/" + file)

    #verify the digests match
    if test_digest != digest:
        raise Exception("ERROR - DIGEST ERROR - DIGEST IN FILE DOES NOT MATCH")
        
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
        file_name=file,
    )

    # TODO: refactor this, it is so ugly!
    if not exists:

        #rel_path = copy_file(file_id, digest, root_id, root_path, file)
        rel_path = file

        # set the file location
        insert_file_location.execute(
            file_id=file_id,
            file_storage_root_id=root_id,
            rel_path=str(rel_path)
        )

        # mark ready to process
        make_posda_file_ready_to_process.execute(file_id)

    if file.startswith('decompressed;'):
        os.unlink(file)


# def copy_file(file_id, digest, root_id, root_path, source_path):
#     rel_path = make_rel_path_from_digest(digest)
#     destination_path = root_path / rel_path

#     # Ensure the parent dir exists
#     destination_path.parent.mkdir(parents=True, exist_ok=True)

#     print(source_path, destination_path)
#     shutil.copy(source_path, destination_path)

#     return rel_path

filename = pargs.plist

# Begin an import event
Query("InsertEditImportEvent").execute(
    import_type="plist import",
    import_comment="test comment",
)

import_event_id = Query("GetImportEventId").get_single_value()
# for row in Query("GetPosdaFileCreationRoot").run():
#     root = tuple(row)

# print(root)

with open(filename) as infile:
    reader = csv.DictReader(infile,delimiter=',')
    for line in reader:
        obj = line["root_path"],line["rel_path"],line["size"],line["digest"]
        print("reading")
        root_id = get_matching_root.get_single_value(
                root_path=line["root_path"])
        if root_id is None:
            root_id = create_new_root.run(
                root_path=line["root_path"])
            print("root_path created")
        else:
            print("root_path exists")
        import_one_file(import_event_id, root_id, obj)
        # break
