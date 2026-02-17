#!/usr/bin/env python3
"""
A new version of the ApplyMasks script
"""
import argparse
# import hashlib
# import tempfile
# import pydicom
import sys
# import os
import csv
# from collections import defaultdict
from posda.database import Database
# from posda.config import Config
from posda.background.process import BackgroundProcess
# from typing import List, Set, Iterator, Tuple, Optional
# from pydicom.sequence import Sequence
# from pydicom.dataset import Dataset
# from pydicom import uid
# from psycopg2.extras import execute_values
# from pprint import pprint


def get_activity_files(args, conn):
    """
    Returns tuples of (file_id, storage_path, media_storage_sop_class, sop_instance_uid)
    """

    activity_id = args.activity_id

    file_query = """
            with files_in_activity as 
            (
                select file_id, activity_timepoint_id
                from activity_timepoint_file
                natural join file
                where activity_timepoint_id = (
                    select max(activity_timepoint_id)
                    from activity_timepoint
                    where activity_id = %s
                )
                and file.is_dicom_file = true                
            )
            select file_id,
                   activity_timepoint_id,
                   storage_path(file_id),
                   media_storage_sop_class,
                   modality,
                   sop_instance_uid,
                   series_instance_uid,
                   study_instance_uid,
                   patient_id,
                   for_uid
            from files_in_activity
            natural left join file_meta
            natural left join file_sop_common
            natural left join file_series
            natural left join file_study
            natural left join file_patient
            natural left join file_for
        """    
    file_rows = []
    cur = conn.cursor()
    cur.execute(file_query, (activity_id,))
    file_rows = cur.fetchall()

    return file_rows


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("background_id", help="the background_subprocess_id")
    parser.add_argument("activity_id", help="the primary activity to run against")
    parser.add_argument("notify", help="user to notify when complete")
    return parser.parse_args()


def generate_arg_report(args):

    print("CheckSeriesExist.py running with the following arguments:")
    print(f"Activity ID: {args.activity_id}")

    print("------------------------------------------")


def main2(args, background):
    generate_arg_report(args)
    conn = Database("posda_files")
    file_rows = get_activity_files(args, conn)


    # Collect the current timepoint and the list of series_instance_uids
    current_timepoint = None
    current_series_uids = set()
    for row in file_rows:
        # row is a tuple: (file_id, activity_timepoint_id, storage_path, media_storage_sop_class, modality, sop_instance_uid, series_instance_uid, study_instance_uid, patient_id, for_uid)
        # activity_timepoint_id is at index 1, series_instance_uid is at index 6
        if current_timepoint is None:
            current_timepoint = row[1]
        series_uid = row[6]
        if series_uid:
            current_series_uids.add(series_uid)

    # For demonstration, print or log the current timepoint and the list of series_instance_uids
    print(f"Current timepoint: {current_timepoint}")
    print(f"Number of SeriesInstanceUIDs in this timepoint: {len(current_series_uids)}")

    # Query for previous existence of each series_instance_uid (not in current activity)
    previous_series = {}
    cur = conn.cursor()
    query = """
        select distinct series_instance_uid, activity_id, activity_timepoint_id
        from file_series
        join activity_timepoint_file using(file_id)
        join activity_timepoint using(activity_timepoint_id)
        where series_instance_uid = any(%s)
          and activity_timepoint_id <> %s
        order by series_instance_uid, activity_id desc, activity_timepoint_id desc
    """
    cur.execute(query, (list(current_series_uids), current_timepoint))
    for row in cur.fetchall():
        series_uid, activity_id, activity_timepoint_id = row
        previous_series.setdefault(series_uid, []).append({
            "activity_id": activity_id,
            "activity_timepoint_id": activity_timepoint_id
        })

    # Report results
    report = background.create_report("Series_Exist")
    writer = csv.writer(report, lineterminator='\n')
    writer.writerow(["series_instance_uid", "exists_elsewhere", "activity_id", "activity_timepoint_id"])
    for series_uid in current_series_uids:
        if series_uid in previous_series:
            for prev in previous_series[series_uid]:
                writer.writerow([series_uid, True, prev["activity_id"], prev["activity_timepoint_id"]])
        else:
            writer.writerow([series_uid, False, None, None])

    background.finish("Complete")


def main(args):
    """
    Main entry point, just wraps the other main and catches
    exceptions, so that the script always finishes. It still
    exits with a nonzero exit code so the script will be flagged
    as failed.
    """
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    try:
        main2(args, background)
    except Exception as e:
        print("FATAL ERROR:", e)
        background.finish("Failed")
        raise e

    return 0


if __name__ == "__main__":
    sys.exit(main(parse_args()))
