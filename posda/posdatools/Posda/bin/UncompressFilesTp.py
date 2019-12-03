#!/usr/bin/python3 -u

from typing import NamedTuple, Iterator, Dict, Tuple, List
import tempfile
import os
import subprocess
import argparse


from posda.activity import Activity
from posda.database import Database
from posda.queries import Query
from posda.main.file import insert_file
from posda.background.process import BackgroundProcess
from posda.util import printe

class XferSyntax(NamedTuple):
    name: str
    uid: str
    compressed: bool

class Abort(RuntimeError): pass

# transfer syntax map
xfer_map = {syntax.uid: syntax for syntax in [
    XferSyntax('Explicit VR Little Endian', '1.2.840.10008.1.2.1', False),
    XferSyntax('Implicit VR Little Endian', '1.2.840.10008.1.2', False),
    XferSyntax('Explicit VR Big Endian', '1.2.840.10008.1.2.2', False),
    XferSyntax('Deflated Explicit VR Little Endian', '1.2.840.10008.1.2.1.99', True),
    XferSyntax('RLE Lossless', '1.2.840.10008.1.2.5', True),
    XferSyntax('JPEG Baseline (Process 1)', '1.2.840.10008.1.2.4.50', True),
    XferSyntax('JPEG Extended (Process 2 and 4)', '1.2.840.10008.1.2.4.51', True),
    XferSyntax('JPEG Lossless (Process 14)', '1.2.840.10008.1.2.4.57', True),
    XferSyntax('JPEG Lossless (Process 14, SV1)', '1.2.840.10008.1.2.4.70', True),
    XferSyntax('JPEG LS Lossless', '1.2.840.10008.1.2.4.80', True),
    XferSyntax('JPEG LS Lossy', '1.2.840.10008.1.2.4.81', True),
    XferSyntax('JPEG2000 Lossless', '1.2.840.10008.1.2.4.90', True),
    XferSyntax('JPEG2000', '1.2.840.10008.1.2.4.91', True),
    XferSyntax('JPEG2000 Multi-component Lossless', '1.2.840.10008.1.2.4.92', True),
    XferSyntax('JPEG2000 Multi-component', '1.2.840.10008.1.2.4.93', True),
]}

def fix_xfer_syntax(filename: str, current_syntax: str):
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

    if (current_syntax == '1.2.840.10008.1.2.1' or 
        current_syntax is None or
        current_syntax == '1.2.840.10008.1.2'):
        return (filename, filename)

    new_filename = tempfile.mktemp(prefix='iffpy')

    subprocess.run(["gdcmconv",
                    "-w",
                    "-i", filename,
                    "-o", new_filename])

    if os.path.exists(new_filename):
        return (new_filename, f"decompressed;{filename}")
    else:
        print(f"Looks like this one failed: {new_filename}")
        return (None, None)

def uncompress_file(path: str, syntax: XferSyntax) -> int:
    new_filename, old_filename = fix_xfer_syntax(path, syntax.uid)
    if new_filename != old_filename:
        file_id = insert_file(new_filename)
        os.unlink(new_filename)  # clean up temporary file
    return file_id

def xfer_syntax_from_timepoint(timepoint: int) -> Iterator[Tuple[int, Dict[str, XferSyntax]]]:
    with Database("posda_files").cursor() as cur:
        cur.execute("""\
            select file_id, xfer_syntax, root_path || '/' || rel_path as path
            from activity_timepoint_file
            natural join file_meta
            natural join file_location
            natural join file_storage_root
            where activity_timepoint_id = %s
        """, [timepoint])

        for file_id, syntax, path in cur:
            try:
                yield file_id, xfer_map[syntax], path
            except KeyError:
                raise Abort("FATAL: Encountered unknown Transfer Syntax: "
                            f"{syntax}. Please contact your Posda Administrator")

def build_new_timepoint(activity_id, file_list: List[int]) -> None:
    # Create the new timepoint
    Query("CreateActivityTimepoint").execute(
        actiity_id=activity_id,
        who_created='none',
        comment='UncompressFilesTp.py',
        creating_user='none'
    )
    tp_id = Query("GetActivityTimepointId").get_single_value()

    with Database("posda_files").cursor() as cur:
        # build a single giant insert query
        args = b','.join([cur.mogrify("(%s, %s)", [tp_id, f]) for f in file_list])
        query = b"""\
            insert into activity_timepoint_file values 
        """ + args

        cur.execute(query)
    return tp_id

def main(args) -> None:
    activity_id = args.activity_id


    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    print("All processing in background")
    background.daemonize()
    background.set_activity_status(f"starting")

    activity = Activity(activity_id)

    new_timepoint_files = []
    edited_count = 0

    try:
        for file_id, syntax, path in xfer_syntax_from_timepoint(activity.latest_timepoint()):
            if syntax.compressed:
                file_id = uncompress_file(path, syntax)
                edited_count += 1
            new_timepoint_files.append(file_id)
            if edited_count % 1000 == 0:
                background.set_activity_status(f"Edited {edited_count}...")
    except Abort as e:
        print(str(e))
        printe("UncompressFilesTp.py aborting due to fatal error: ", str(e))
        background.finish(f"Aborted due to fatal error")
        return


    print(f"Successfully processed {len(new_timepoint_files)} files, "
          f"uncompressed {edited_count}.")
    if edited_count == 0:
        print("No files edited, no need to create a new timepoint")
    else:
        tp_id = build_new_timepoint(activity_id, new_timepoint_files)
        print(f"Created new timepoint {tp_id}")

    background.finish(f"Complete - Edited {edited_count} files.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Uncompress any compressed files in a Timepoint")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
