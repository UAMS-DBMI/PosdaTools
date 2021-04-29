#!/usr/bin/env python3

import psycopg2
import csv
import sys
import argparse
from posda.database import Database
from posda.background.process import BackgroundProcess


# This query uses a recursive CTE to walk the edit history
# to find the origin file for any given file_id. It then returns
# the sop, study, and series UIDs for the given file and the origin
# file.
bigquery = """\
with recursive the_initial_file as (
    select %s as file_id
),
test as (
    select
        file.file_id,
        file.file_id as orig_file_id,
        from_file_digest,
        file_name as path
    from
        file
        join dicom_edit_compare dec on dec.to_file_digest = file.digest
        join file_import on file.file_id = file_import.file_id
    where
        file.file_id = (select file_id from the_initial_file)
                and dec.to_file_digest <> dec.from_file_digest
    union
    select
        file.file_id,
        test.orig_file_id,
        dec.from_file_digest,
        file_name as path
    from
        test
        join dicom_edit_compare dec on dec.to_file_digest = test.from_file_digest
        join file on file.digest = test.from_file_digest
        join file_import on file.file_id = file_import.file_id
        where dec.to_file_digest <> dec.from_file_digest
),
last_item_in_recursive_list as (
    select
        *
    from
        test
    order by
        file_id
    limit 1
),
first_file as (
    select
        file.*
    from
        file
        join last_item_in_recursive_list on file.digest = last_item_in_recursive_list.from_file_digest
        join file_import on file_import.file_id = file.file_id
)
select
    'original' as what,
    sop_instance_uid,
    series_instance_uid,
    study_instance_uid
from first_file
natural join file_series
natural join file_sop_common
natural join file_study

union

select
    'current' as what,
    sop_instance_uid,
    series_instance_uid,
    study_instance_uid
from file
natural join file_series
natural join file_sop_common
natural join file_study
where file_id = (select file_id from the_initial_file)

order by what desc
"""

def get_map(cur, file_id):
    cur.execute(bigquery, [file_id])

    _, o_sop, o_series, o_study = cur.fetchone()
    _, c_sop, c_series, c_study = cur.fetchone()

    return [
        o_sop, o_series, o_study,
        c_sop, c_series, c_study,
    ]

def get_file_ids(cur, timepoint_id):
    query = """\
        select
            file_id
        from
            activity_timepoint_file
        where
            activity_timepoint_id = %s
    """

    cur.execute(query, [timepoint_id])
    return [i for i, in cur]



def main(args):

    background = BackgroundProcess(args.background_id, args.notify)
    background.daemonize()

    print(f"Creating hashed UID map for activity_timepoint_id {args.timepoint_id}")
    # background.set_activity_status("Beginning...")
    report = background.create_report("UIDMap")


    with Database("posda_files") as conn:
        writer = csv.writer(report)
        cur = conn.cursor()
        file_ids = get_file_ids(cur, args.timepoint_id)

        writer.writerow([
            'original_sop',
            'original_series',
            'original_study',
            'current_sop',
            'current_series',
            'current_study',
        ])
        for id in file_ids:
            writer.writerow(get_map(cur, id))

    background.finish("Complete")


def parse_args():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument('background_id')
    parser.add_argument('notify')
    parser.add_argument('timepoint_id', type=int)

    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    main(args)
