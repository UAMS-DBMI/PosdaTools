#!/usr/bin/python3 -u
ABOUT="""\
Apply Masks (or other masker operations) to the current timepoint.

"""

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from psycopg2.extras import execute_values
import csv

import sys
import argparse
from typing import List, Set


def main(args):
    background = BackgroundProcess(args.background_id,
                                   args.notify,
                                   args.activity_id)
    background.daemonize()

    print(f"Applying Masks for activity {args.activity_id}, "
          f"visual_review_instance_id {args.visual_review_instance_id}")

    db = Database("posda_files")

    ## Get the latest tp
    latest_timepoint = get_latest_timepoint(db, args.activity_id)
    print(f"Starting with timepoint {latest_timepoint}")

    background.set_activity_status("Getting source files")
    ## get all files in latest tp
    all_files = get_files_in_timepoint(db, latest_timepoint)

    ## Get the set of input images to the masked IECs (masked and nonmaskable status)
    premasked_images = get_input_images_to_masked_iecs(db, args.visual_review_instance_id)
    premasked_image_ids = [i.file_id for i in premasked_images]
    premasked_image_series = {(i.series_instance_uid, i.project_name, i.site_name) 
                              for i in premasked_images}

    ## Get the file_ids from all outputs (from the import events) for the masked IECs
    masked_image_ids = get_output_images_to_masked_iecs(db, args.visual_review_instance_id)

    ## Add the output fiels to the all_files set
    all_files.update(masked_image_ids)

    ## Get the list of series from the "input images" set and produce a report
    report = background.create_report(f"Premasked Series")
    populate_edit_skeleton_report(report, premasked_image_series, args)

    background.set_activity_status("Creating new timepoint")
    ## Create a new timepoint with the new all_files set
    new_tp = create_activity_timepoint(args, db)
    print(f"Creating new timepoint with id {new_tp}")
    insert_files_into_timepoint(db, new_tp, all_files)

    background.finish("Complete")

def populate_edit_skeleton_report(report, premasked_image_series, args):

    writer = csv.writer(report)
    writer.writerow([
        "series_instance_uid",
        "collection_name",
        "site_name",
        "op",
        "tag",
        "val1",
        "val2",
        "Operation",
        "edit_description",
        "notify",
        "activity_id"
    ])

    for i, (series, collection, site) in enumerate(premasked_image_series):
        if i == 0:
            writer.writerow([
                series, collection, site,
                None, None, None, None, 
                "BackgroundEditTp", # Operation
                "Edit for ApplyMasks", # edit_description
                args.notify,
                args.activity_id
            ])
        else:
            writer.writerow([series, collection, site])

    writer.writerow([None, None, None, "set_tag", "<(0013,0012)>", "new-site-name"])


def create_activity_timepoint(args, db) -> int:
    query = """\
        insert into activity_timepoint(
            activity_id,
            when_created,
            who_created,
            comment,
            creating_user
        ) values (
            %s, now(), %s, %s, %s
        )
        returning activity_timepoint_id
    """

    with db.cursor() as cur:
        cur.execute(
            query, 
            [
                args.activity_id,
                args.notify,
                "ApplyMasks.py",
                args.notify
            ]
        )

        for activity_timepoint_id, in cur:
            return activity_timepoint_id

def insert_files_into_timepoint(db: Database,
                                timepoint_id: int,
                                file_ids: List[int]) -> None:

    # populate it with the files from above
    with db.cursor() as cur:
        query = """\
            insert into activity_timepoint_file
            values %s
        """
        value_list = [(timepoint_id, file_id) 
                      for file_id in file_ids]
        # execute_values is a new method in psycopg2 2.7+ 
        # which can be used to map an object onto a values
        # clause and insert bulk values very fast.
        #
        # In thise case, value_list looks like: 
        # [(42, 1), (42, 2), (42, 3)]
        execute_values(cur, query, value_list)

def get_files_in_timepoint(db, timepoint_id: int) -> Set[int]:
    query = """
        select file_id
        from activity_timepoint_file
        where activity_timepoint_id = %s
    """

    file_ids = []
    with db.cursor() as cur:
        cur.execute(query, [timepoint_id])
        results = cur.fetchall()

        return {r[0] for r in results}

def get_input_images_to_masked_iecs(db, visual_review_instance_id: int):
    query = """\
        select
            file_id, series_instance_uid, project_name, site_name
        from
            image_equivalence_class
            natural join image_equivalence_class_input_image
            natural join masking
            natural join file_series
            natural join ctp_file
        where
            visual_review_instance_id = %s
            and masking_status in ('accepted', 'nonmaskable')
    """

    with db.cursor() as cur:
        cur.execute(query, [visual_review_instance_id])
        results = cur.fetchall()

        # return {r[0] for r in results}
        # return [(r.file_id, r.series_instance_uid) for r in results]
        return results

def get_output_images_to_masked_iecs(db, visual_review_instance_id: int):
    query = """\
        select
            file_id
        from
            image_equivalence_class
            natural join masking
            natural join file_import
        where
            visual_review_instance_id = %s
            and masking_status in ('accepted', 'nonmaskable')
    """

    with db.cursor() as cur:
        cur.execute(query, [visual_review_instance_id])
        results = cur.fetchall()

        return [r.file_id for r in results]

def get_latest_timepoint(db, activity_id: int) -> int:
    query = """\
        select max(activity_timepoint_id)
        from activity_timepoint
        where activity_id = %s
    """

    with db.cursor() as cur:
        cur.execute(query, [activity_id])
        for tp_id, in cur:
            return tp_id

    return 0


def parse_args():
    parser = argparse.ArgumentParser(description=ABOUT)
    parser.add_argument('background_id', help='the background_subprocess_id')
    parser.add_argument(
        'activity_id',
        help='the activity to create the new timepoint in'
    )
    parser.add_argument(
        'visual_review_instance_id',
        help='the visual review the masks were created in'
    )
    parser.add_argument('notify', help='user to notify when complete')

    return parser.parse_args()


if __name__ == '__main__':
    main(parse_args())
