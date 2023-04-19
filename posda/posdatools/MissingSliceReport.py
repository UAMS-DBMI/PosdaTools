#!/usr/bin/python3 -u
HELP="""\

Convert Big Endian DICOM files to Explicit VR Little Endian.

Big Endian is deprecated and Posda cannot directly edit them.

"""

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.main.file import insert_file

import tempfile
import subprocess
import os
import argparse


def convert_file(filename):
    output_filename = tempfile.mktemp(prefix='posdatmp', suffix='.dcm')
    ret_code = subprocess.check_call([
        "gdcmconv",
        "-w",
        "-i", filename,
        "-o", output_filename
    ])
    if ret_code != 0:
        raise RuntimeError(f"failed to convert file: {filename}")

    file_id = insert_file(output_filename, comment="ConvertBigEndianToLittle")
    os.unlink(output_filename)
    return file_id

def maintwo(background, activity_id, notify):

    with Database("posda_files").cursor() as cur:
        cur.execute("""\
            select root_path || '/' || rel_path as path
            from activity_timepoint_file
            natural join file
            natural join file_location
            natural join file_storage_root
            where
                activity_timepoint_id = (
                    select max(activity_timepoint_id)
                    from activity_timepoint
                    where activity_id = %s
                )
            and is_dicom_file = true
        """, [activity_id])

        new_file_ids = []

        for i, row in enumerate(cur):
            new_file_ids.append(convert_file(row.path))
            background.set_activity_status(f'Processing {i} of ??')

        print(f"Converted {i + 1} files.")

        # create a new timepoint with these files
        cur.execute("""\
            insert into activity_timepoint(
                activity_id, when_created, who_created, comment, creating_user
            ) values (
                %s, now(), %s, %s, %s
            )
            returning activity_timepoint_id
        """, [activity_id, notify, 'Converting Big Endian to Little', notify])

        tp_id, = cur.fetchone()
        print(f"Created new timepoint: {tp_id}")

        # add them all to the new tp
        cur.executemany("""\
            insert into activity_timepoint_file
            values (%s, %s)
        """, [(tp_id, i) for i in new_file_ids])

        cur.connection.commit()


def main(background_id, activity_id, notify):
    background = BackgroundProcess(background_id, notify, activity_id)

    background.print_to_email(
        f"Converting Big Endian to Little Endian for Activity {activity_id}"
    )

    background.daemonize()

    background.set_activity_status('Beginning')

    maintwo(background, activity_id, notify)

    background.finish("Complete!")


def parse_args():
    parser = argparse.ArgumentParser(description=HELP)
    parser.add_argument(
        'background_id',
        help='background_subprocess_id, should be supplied by Posda'
    )
    parser.add_argument('activity_id', help='the activity you want to convert')
    parser.add_argument('notify', help='the person to notify when complete')

    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()

    main(args.background_id, args.activity_id, args.notify)

