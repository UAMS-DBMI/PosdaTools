#!/usr/bin/env python3
"""
A new version of the ApplyMasks script
"""
import argparse
import hashlib
import tempfile
import pydicom
import sys
import os
import csv
from collections import defaultdict
from posda.database import Database
from posda.main.file import insert_file
from typing import List, Set, Iterator, Tuple

from posda.database import Database
from posda.config import Config
from pydicom.sequence import Sequence
from pydicom.dataset import Dataset
from posda.background.process import BackgroundProcess
from pydicom import uid
from psycopg2.extras import execute_values

from pprint import pprint

# the real one
TCIA_UID_ROOT = "1.3.6.1.4.1.14519.5.2.1"
# for testing only, use an easily identifable root
# TCIA_UID_ROOT = "1207885"

TAGS_TO_SCAN = [
    "SOPInstanceUID",
    "ReferencedSOPInstanceUID",
    "MultiFrameSourceSOPInstanceUID",
    "SeriesInstanceUID",
    "SOPInstanceUIDOfConcatenationSource",
]


def walk_dataset(ds: Dataset, depth: int = 0) -> Iterator[Tuple[int, object]]:
    for elem in ds:
        if isinstance(elem.value, Sequence):
            for i, item in enumerate(elem.value):
                yield from walk_dataset(item, depth + 1)
        elif isinstance(elem.value, Dataset):
            yield from walk_dataset(elem.value, depth + 1)
        # skip the pixel data
        elif elem.tag == (0x7FE0, 0x0010):
            continue
        else:
            # Leaf node
            yield depth, elem

def walk_dataset_for_referencing(ds: Dataset) -> Iterator[Tuple[int, object]]:
    """
    Walk the dataset and yield only those tags we care about.

    We care about tags that are in TAGS_TO_SCAN and are NOT at the root
    level (that is, have a depth over 0).
    """
    for depth, elem in walk_dataset(ds):
        if elem.keyword in TAGS_TO_SCAN and depth > 0:
            yield depth, elem

def create_activity_timepoint(activity_id, notify, db) -> int:
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
        cur.execute(query, [activity_id, notify, "NewApplyMasks.py", notify])

        for (activity_timepoint_id,) in cur:
            return activity_timepoint_id

        return -1


def get_output_images_to_masked_iecs(db, visual_review_instance_id: int, function_list: List[str]) -> List:
    """
    Get the files of the post-masked images, but only DICOM files
    Returns a list of tuples of (file_id, storage_path, media_storage_sop_class, sop_instance_uid)
    """
    query = """\
        select
            file_id,
            storage_path(file_id),
            media_storage_sop_class,
            sop_instance_uid
        from
            image_equivalence_class
            natural join masking
            natural join file_import
            natural join file
            natural join file_meta
            natural join file_sop_common
        where
            visual_review_instance_id = %s
            and is_dicom_file = true
            and masking_status = 'accepted'
            and masking_parameters ->> 'function' = ANY(%s)
    """

    with db.cursor() as cur:
        cur.execute(query, [visual_review_instance_id, function_list])
        results = cur.fetchall()

        return results


def hash_uid(uid, uid_root):
    md5 = hashlib.md5(uid.encode())
    new_uid = f"{uid_root}.{int(md5.hexdigest(), 16)}"[:64]
    return new_uid


def insert_files_into_timepoint(
    db: Database, timepoint_id: int, file_ids: List[int]
) -> None:

    # populate it with the files from above
    with db.cursor() as cur:
        query = """\
            insert into activity_timepoint_file
            values %s
        """
        value_list = [(timepoint_id, file_id) for file_id in file_ids]
        # execute_values is a new method in psycopg2 2.7+
        # which can be used to map an object onto a values
        # clause and insert bulk values very fast.
        #
        # In thise case, value_list looks like:
        # [(42, 1), (42, 2), (42, 3)]
        execute_values(cur, query, value_list)

def insert_files_into_check_table(
    db: Database, timepoint_id: int, file_ids: List[int]
) -> None:

    # populate it with the files from above
    with db.cursor() as cur:
        query = """\
            insert into quasar.timepoint_check
            values %s
        """
        value_list = [(timepoint_id, file_id) for file_id in file_ids]
        # execute_values is a new method in psycopg2 2.7+
        # which can be used to map an object onto a values
        # clause and insert bulk values very fast.
        #
        # In thise case, value_list looks like:
        # [(42, 1), (42, 2), (42, 3)]
        execute_values(cur, query, value_list)

def get_files_in_activity(db, activity_id: int) -> Set[int]:
    """
    Get all files in the current timepoint for the activity
    """
    query = """
        select
                file_id
        from
                activity_timepoint_file
        where
                activity_timepoint_id = (
                        select max(activity_timepoint_id)
                        from activity_timepoint
                        where activity_id = %s
                )
    """

    with db.cursor() as cur:
        cur.execute(query, [activity_id])
        results = cur.fetchall()

        return {r[0] for r in results}


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("background_id", help="the background_subprocess_id")
    parser.add_argument("activity_id", help="the primary activity to run against")
    parser.add_argument("notify", help="user to notify when complete")
    parser.add_argument(
        "visual_review_instance_id", help="the visual review the masks were created in"
    )
    parser.add_argument("process_masks", help="if set, process the Mask items")
    parser.add_argument(
        "process_sliceremove", help="if set, process the Slice Remove items"
    )
    parser.add_argument("process_blackout", help="if set, process the Blackout items")
    return parser.parse_args()


def generate_arg_report(args):
    to_process = []
    if args.process_masks:
        to_process.append("Masks")
    if args.process_sliceremove:
        to_process.append("Slice Remove")
    if args.process_blackout:
        to_process.append("Blackout")

    print("NewApplyMasks.py running with the following arguments:")
    print(f"Activity ID: {args.activity_id}")
    print(f"Visual Review Instance ID: {args.visual_review_instance_id}")

    print("Will process:", ", ".join(to_process))
    print("Will generate edit skeleton for moving pre-masked files")

    print("------------------------------------------")


def verify_iec_status(visual_review_instance_id, conn):
    cur = conn.cursor()
    cur.execute(
        """
            select
                masking_status,
                count(*)
            from
                masking
                natural join image_equivalence_class
            where
                visual_review_instance_id = %s
                and masking_status not in ('accepted', 'skipped')
            group by 1
        """,
        (visual_review_instance_id,),
    )

    invalid_statuses = cur.fetchall()

    if len(invalid_statuses) > 0:
        print("ERROR: There are IECs in the VR that are not 'accepted' or 'skipped'.")
        print("Please resolve these before proceeding.")

        print("Invalid IEC statuses:")
        for status, count in invalid_statuses:
            # print(f"{count} are set to {status}")
            print(f"\t{status}: {count} IECs")

        raise ValueError("IEC status verification failed.")
        # print("NOTE: continuing anyway, uncomment above for PROD")


def get_orphaned_sops(visual_review_instance_id, conn):
    cur = conn.cursor()
    cur.execute(
        """
        /*
                Get "orphaned" IECs in the VR: those IECs (which are NOT going to be
                processed) that are part of series which ARE going to be processed

                Inputs:
                        visual_review_instance_id
        */
        with all_iecs_with_function as (
                /*
                        Gets all IECs in the given Visual Review (that have been flagged
                        for masking) along with the selected function, and status.
                */
                select distinct
                        series_instance_uid,
                        image_equivalence_class_id,
                        masking_parameters ->> 'function' as function,
                        masking_status
                from
                        image_equivalence_class
                        natural join image_equivalence_class_input_image
                        natural join file_series
                        natural left join masking
                where
                        visual_review_instance_id = %s
                order by 1
        ), iecs_to_work_on as (
                /*
                        Gets the IECs in the VR we plan to work on (along with their series)
                */
                select
                        image_equivalence_class_id,
                        series_instance_uid
                from
                        all_iecs_with_function
                where
                        masking_status = 'accepted'
        ), iecs_not_to_work_on as (
                /*
                        Gets the IECs in the VR we do not plan to work on (along with their series)
                        (This is mostly the opposite of the previous one)
                */
                select
                        image_equivalence_class_id,
                        series_instance_uid,
                        function,
                        masking_status
                from all_iecs_with_function
                /* NOTE: We include all functions here, not just the selected one,
                                under the assumption that anything set to 'accepted' is
                                not an orphan, but will be processed eventually */
                where not masking_status = 'accepted' or masking_status is null
        ), orphaned_iecs as (
                        select
                                series_instance_uid,
                                iecs_not_to_work_on.image_equivalence_class_id,
                                        iecs_not_to_work_on.function,
                                        iecs_not_to_work_on.masking_status
                        from
                                iecs_not_to_work_on
                                join iecs_to_work_on using (series_instance_uid)
                )

                select distinct sop_instance_uid
                from orphaned_iecs
                natural join image_equivalence_class_input_image
                natural join file_sop_common
    """,
        (visual_review_instance_id,),
    )

    return {row.sop_instance_uid for row in cur}


def get_referencing_segs(visual_review_instance_id, activity_id, function, conn):
    cur = conn.cursor()
    cur.execute(
        """
        with all_iecs_with_function as (
            /*
            Gets all IECs in the given Visual Review (that have been flagged
            for masking) along with the selected function, and status.
            */
            select distinct
                series_instance_uid,
                image_equivalence_class_id,
                masking_parameters ->> 'function' as function,
                masking_status
            from
                image_equivalence_class
                natural join image_equivalence_class_input_image
                natural join masking
                natural join file_series
            where
                visual_review_instance_id = %s
            order by
                1
        ), iecs_to_work_on as (
            /*
            Gets the IECs in the VR we plan to work on (along with their series)
            */
            select
                image_equivalence_class_id,
                series_instance_uid
            from
                all_iecs_with_function
            where
                masking_status = 'accepted'
                and function = %s
        ), files_to_work_on as (
                select file_id
                from image_equivalence_class_input_image
                natural join iecs_to_work_on
        ), files_in_activity as (
                select
                    file_id
                from
                    activity_timepoint_file
                where
                    activity_timepoint_id = (
                            select max(activity_timepoint_id)
                            from activity_timepoint
                            where activity_id = %s
                    )
        )
        /* Find seg files that reference any of the files we plan to modify */
        select distinct seg_id as file_id
        from files_to_work_on
        natural join file_seg_image_linkage
        natural join files_in_activity
    """,
        (visual_review_instance_id, function, activity_id),
    )

    return [row.file_id for row in cur]


def get_referencing_rois(visual_review_instance_id, activity_id, function, conn):
    # TODO: this query is wrong, roi_id is NOT a file_id, the query needs to be
    # adjusted to find the actual file_id via the referenced_sop_instance_uid
    cur = conn.cursor()
    cur.execute(
        """
        with all_iecs_with_function as (
            /*
            Gets all IECs in the given Visual Review (that have been flagged
            for masking) along with the selected function, and status.
            */
            select distinct
                series_instance_uid,
                image_equivalence_class_id,
                masking_parameters ->> 'function' as function,
                masking_status
            from
                image_equivalence_class
                natural join image_equivalence_class_input_image
                natural join masking
                natural join file_series
            where
                visual_review_instance_id = %s
            order by
                1
        ), iecs_to_work_on as (
            /*
            Gets the IECs in the VR we plan to work on (along with their series)
            */
            select
                image_equivalence_class_id,
                series_instance_uid
            from
                all_iecs_with_function
            where
                masking_status = 'accepted'
                and function = %s
        ), files_to_work_on as (
                select file_id
                from image_equivalence_class_input_image
                natural join iecs_to_work_on
        ), files_in_activity as (
                select
                    file_id
                from
                    activity_timepoint_file
                where
                    activity_timepoint_id = (
                            select max(activity_timepoint_id)
                            from activity_timepoint
                            where activity_id = %s
                    )
        )
        /* Find seg files that reference any of the files we plan to modify */
        select distinct roi_id as file_id
        from files_to_work_on
        natural join file_roi_image_linkage
        natural join files_in_activity
    """,
        (visual_review_instance_id, function, activity_id),
    )

    return [row.file_id for row in cur]


def get_referencing_regs(visual_review_instance_id, activity_id, function, conn):
    """

    The plan:
    1. Identify all REGs in the activity
    2. For each REG, check if it references any of the files we plan to work on
        (in the VR and of the function)
    3. If it does, return the REG file_id

    """

    cur = conn.cursor()
    # TODO: this is not done, look at the other ones, this needs to select only
    # files that we are "working on" (in the activity, the function, and the VR)
    cur.execute(
        """
    with files_in_activity as (
            select
                    file_id
            from
                    activity_timepoint_file
            where
                    activity_timepoint_id = (
                            select max(activity_timepoint_id)
                            from activity_timepoint
                            where activity_id = %s
                    )
    )

    select storage_path(file_id), file_id
    from files_in_activity
    natural join file_series
    where modality = 'REG'
    """,
        (activity_id,),
    )

    for row in cur:
        print(row)


def get_dicom_sequence_items_list(ds, sequence_name, item_names):
    """
    Extracts items from a DICOM sequence given a sequence and item names.

    sequence_name: The name of a top‐level sequence attribute in the DICOM file.
    item_names: A list of leaf item names (DataElement keywords) to extract.

    Recursively searches all items under sequence_name looking for any
    DataElements with a keyword listed in item_names, and returns a list of
    tuples containing their value and their full path.
    """

    if not hasattr(ds, sequence_name):
        return []

    seq = getattr(ds, sequence_name)
    if not isinstance(seq, (Sequence, list)):
        return []

    results = []

    def recurse(dataset, path):
        # if it is not a Dataset or Sequence, we can't recurse further
        if not isinstance(dataset, (pydicom.dataset.Dataset, Sequence)):
            return
        for data_element in dataset:
            keyword = data_element.keyword
            # if this element is one of the requested leaf items, collect its value and path
            if keyword in item_names:
                full_path = ".".join(path + [keyword])
                results.append((data_element.value, full_path, data_element))
            # if the value is itself a sequence of datasets, recurse into each
            val = data_element.value
            if isinstance(val, (Sequence, list)):
                for idx, item in enumerate(val):
                    recurse(item, path + [f"{keyword}[{idx}]"])

    # start recursion on each item in the top-level sequence
    for idx, item in enumerate(seq):
        recurse(item, [f"{sequence_name}[{idx}]"])

    return results


def load_map():
    """
    Load the mapping of SOP Class UIDs to sequence keys and element keys,
    used to identify which elements need to have their UIDs hashed.
    """

    # eventual structure:
    # sop_map = {
    #     'sop_class_uid': {
    #         'seq_key': [ ele_key1, ele_key2, ... ],
    #     }
    # }
    sop_map = defaultdict(lambda: defaultdict(set))

    ## The DICOM standard is stored in the dicom_dd database.
    with Database("dicom_dd") as conn:
        cur = conn.cursor()
        cur.execute(
            """
            with sequences as
            (
                select tag as seq_tag, 
                    name as seq_name, 
                    keyword as seq_key 
                from dicom_element
                where lower(name) like '%sequence%'
                and (
                    lower(name) like '%reference%'
                    or lower(name) like '%source%'
                    or lower(name) like '%derivation%'
                    or lower(name) like '%evidence%'
                    or lower(name) like '%procedure%'
                    or lower(name) like '%instance%'
                    or lower(name) like '%matrix%'
                    or lower(name) like '%fiducial%'
                    or lower(name) like '%contour%'
                    or lower(name) like '%functional%'
                )
            ),
            elements as
            (
                select tag as ele_tag, 
                    name as ele_name, 
                    keyword as ele_key
                from dicom_element
                where lower(name) like '%instance%uid%'
                and (
                    lower(name) like '%series%'
                    or lower(name) like '%sop%'
                )
            )
            select
            req.sop_class_uid,
            dsc.sop_class_name,
            req.tag_full,
            seq.seq_tag,
            seq.seq_key,
            ele.ele_tag,
            ele.ele_key
            from dicom_class_iod_requirements req
            join dicom_sop_classes dsc 
            on dsc.sop_class_uid = req.sop_class_uid 
            join dicom_class_iod_requirements_tags rt_seq
            on req.tag_full = rt_seq.tag_full
            join sequences seq
            on rt_seq.tag = seq.seq_tag
            join dicom_class_iod_requirements_tags rt_ele
            on req.tag_full = rt_ele.tag_full
            join elements ele
            on rt_ele.tag = ele.ele_tag
            order by req.sop_class_uid, req.tag_full
        """
        )

        for row in cur:
            sop_map[row.sop_class_uid][row.seq_key].add(row.ele_key)

    return sop_map


def get_edited_files(visual_review_instance_id, function_list, conn):
    """
    Get all file_ids of files that were edited in the given Visual Review
    with the specified function.
    """
    cur = conn.cursor()
    cur.execute(
        """
        with all_iecs_with_function as (
                /*
                Gets all IECs in the given Visual Review (that have been flagged
                for masking) along with the selected function, and status.
                */
                select distinct
                        series_instance_uid,
                        image_equivalence_class_id,
                        masking_parameters ->> 'function' as function,
                        masking_status
                from
                        image_equivalence_class
                        natural join image_equivalence_class_input_image
                        natural join masking
                        natural join file_series
                where
                        visual_review_instance_id = %s
                order by
                        1
        ), iecs_to_work_on as (
                /*
                Gets the IECs in the VR we plan to work on (along with their series)
                */
                select
                        image_equivalence_class_id,
                        series_instance_uid
                from
                        all_iecs_with_function
                where
                        masking_status = 'accepted'
                        and function = ANY(%s)
        ), files_to_work_on as (
                        select file_id
                        from image_equivalence_class_input_image
                        natural join iecs_to_work_on
        )

        select distinct file_id
        from files_to_work_on
    """,
        (visual_review_instance_id, function_list),
    )

    return {row.file_id for row in cur}


def get_edited_sops(visual_review_instance_id, function_list: List[str], conn):
    """
    Get all SOP and Series Instance UIDs of files that were edited in the given Visual Review
    with the specified function. These are the UIDs BEFORE being processed
    by Masker (which modifies them)
    """
    cur = conn.cursor()
    cur.execute(
        """
        with all_iecs_with_function as (
                /*
                Gets all IECs in the given Visual Review (that have been flagged
                for masking) along with the selected function, and status.
                */
                select distinct
                        series_instance_uid,
                        image_equivalence_class_id,
                        masking_parameters ->> 'function' as function,
                        masking_status
                from
                        image_equivalence_class
                        natural join image_equivalence_class_input_image
                        natural join masking
                        natural join file_series
                where
                        visual_review_instance_id = %s
                order by 1
        ), iecs_to_work_on as (
                /*
                Gets the IECs in the VR we plan to work on (along with their series)
                */
                select
                        image_equivalence_class_id,
                        series_instance_uid
                from
                        all_iecs_with_function
                where
                        masking_status = 'accepted'
                        and function = ANY(%s)
        ), files_to_work_on as (
                select file_id
                from image_equivalence_class_input_image
                natural join iecs_to_work_on
        )

        select distinct sop_instance_uid, series_instance_uid
        from files_to_work_on
        natural join file_sop_common
        natural join file_series
        """,
        (visual_review_instance_id, function_list),
    )

    rows = cur.fetchall()
    return {row.sop_instance_uid for row in rows}, {row.series_instance_uid for row in rows}

def get_all_files_in_timepoint(timepoint_id, conn):
    """
    Returns tuples of (file_id, storage_path, media_storage_sop_class, sop_instance_uid)
    """
    cur = conn.cursor()
    cur.execute(
        """
        with files_in_activity as (
            select
                file_id
            from
                activity_timepoint_file
            where
                activity_timepoint_id = %s
        )
        select 
            file_id,
            storage_path(file_id),
            media_storage_sop_class,
            sop_instance_uid
        from files_in_activity
        natural join file_meta
        natural join file_sop_common
    """,
        (timepoint_id,),
    )

    return cur.fetchall()

def get_all_files_in_activity(activity_id, conn):
    """
    Returns a generator that yields tuples of (file_id, storage_path, media_storage_sop_class, sop_instance_uid)
    """
    cur = conn.cursor()
    cur.execute(
        """
        with files_in_activity as (
            select
                file_id
            from
                activity_timepoint_file
            where
                activity_timepoint_id = (
                    select max(activity_timepoint_id)
                    from activity_timepoint
                    where activity_id = %s
                )
        )
        select 
            file_id,
            storage_path(file_id),
            media_storage_sop_class,
            sop_instance_uid
        from files_in_activity
        natural join file_meta
        natural join file_sop_common
    """,
        (activity_id,),
    )

    return cur.fetchall()


def create_report_from_files(report, files, notify, comment):
    writer = csv.writer(report)
    writer.writerow(
        [
            "file_id",
            "op",
            "tag",
            "val1",
            "val2",
            "Operation",
            "activity_id",
            "comment",
            "notify",
        ]
    )

    # write the operation row
    writer.writerow(
        [
            None,
            None,
            None,
            None,
            None,
            "AddFilesToTimepoint",  # Operation
            None,
            comment,
            notify,
        ]
    )
    # write a second operation row, curators will choose one
    writer.writerow(
        [
            None,
            None,
            None,
            None,
            None,
            "CreateActivityTimepointFromFileList",  # Operation
            None,
            comment,
            notify,
        ]
    )

    for file_id in files:
        writer.writerow([file_id])


def import_edits(edit_list):
    print(f"Importing {len(edit_list)} edited files")
    new_files = []
    for old_file_id, old_sop, new_sop, new_filename in edit_list:
        new_file_id = insert_file(new_filename, comment="NewApplyMasks")
        new_files.append(new_file_id)
        ## TODO: Add row to dicom_edit_compare?

    return new_files


def update_timepoint(activity_id, notify, files_to_remove, files_to_add, conn):
    print("Updating timepoint with new files...")
    print(f"Replacing {len(files_to_remove)} files with {len(files_to_add)} new files")

    if len(files_to_remove) != len(files_to_add):
        raise ValueError(
            "The number of files to remove and files to add should be the same. "
            "Possibly files are missing from the masking import events?"
        )

    ## Sanity check, these files should not overlap
    if len(set(files_to_remove).intersection(set(files_to_add))) > 0:
        raise ValueError(
            "Files to remove and files to add should not overlap, something is very wrong."
        )

    original_files = get_files_in_activity(conn, activity_id)

    new_timepoint = create_activity_timepoint(activity_id, notify, conn)
    files_to_insert = original_files.union(set(files_to_add)).difference(
        set(files_to_remove)
    )

    if len(files_to_insert) != len(original_files):
        raise ValueError(
            "The number of files in the new timepoint should be the same as the original. "
            "Something is very wrong."
        )

    insert_files_into_timepoint(conn, new_timepoint, list(files_to_insert))

    # return the list of files that were not edited or changed
    return original_files.difference(files_to_remove)


# #--------------------------------------------------
# # FOR LOCAL TESTING
# #--------------------------------------------------
# import requests
# from io import BytesIO

# def call_api(endpoint, call_type):
#     API_URL = f'{Config.get("internal-api-url")}/v1{endpoint}'
#     HEADERS = {'Authorization': f'Bearer {Config.get("api_system_token")}'}
#     try:
#         if call_type == 0:
#             response = requests.get(API_URL,headers=HEADERS)
#         elif call_type == 1:
#             response = requests.patch(API_URL,headers=HEADERS)
#         elif call_type == 2:
#             response = requests.put(API_URL,headers=HEADERS)
#         if response.status_code == 200:
#             return response, API_URL, True
#         print(f'Bad response: {response.status_code} - {response.text}')
#     except Exception as e:
#         print(f'Error processing request: {e}')
#     return None, API_URL, False


# def get_file_data(file_id):
#     resp, _, success = call_api(f'/files/{file_id}/data', 0)
#     return resp.content if success else None

# #--------------------------------------------------


def main(args, temp_dir):
    """
    Main entry point, just wraps the other main and catches
    exceptions, so that the script always finishes. It still
    exits with a nonzero exit code so the script will be flagged
    as failed.
    """
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    try:
        main2(args, temp_dir, background)
    except Exception as e:
        print("FATAL ERROR:", e)
        background.finish("Failed")
        raise e

    return 0


def main2(args, temp_dir, background):

    
    # TODO: (from email)
    # replace pre-masked with masked (that is, after getting the files form 
    # the current timepoint, replace the pre-masked files (by sop) with
    # the masked ones (output from masker)
    #
    # if masked don't rehash (during the loop, if a file is edited, check
    # if it's in the masked set before deciding to hash UIDs. If it is, skip 
    # the hashing step)

    generate_arg_report(args)

    conn = Database("posda_files")
    ## Verify all IECs in the VR are set to "accepted" or "skipped"
    verify_iec_status(args.visual_review_instance_id, conn)

    ## Identify orphaned files from masked series that didn’t get masked (scouts, etc.)
    orphan_sops = get_orphaned_sops(args.visual_review_instance_id, conn)

    # Map of SOP Class UIDs to sequences that need hashed
    # sop_map = load_map()

    function_list = [
        *(["mask"] if args.process_masks else []),
        *(["sliceremove"] if args.process_sliceremove else []),
        *(["blackout"] if args.process_blackout else []),
    ]
    premasked_sops, premasked_series = get_edited_sops(
        args.visual_review_instance_id, function_list, conn)
    premasked_files = get_edited_files(
        args.visual_review_instance_id, function_list, conn
    )

    print(len(premasked_sops), "SOPs to be processed")

    ## Sanity check, these two sets should not overlap
    if len(orphan_sops.intersection(premasked_sops)) > 0:
        # count of orphaned sops
        print("Orphaned SOPs:", len(orphan_sops))
        print("Masked SOPs:", len(premasked_sops))
        print(orphan_sops.intersection(premasked_sops))
        raise ValueError(
            "Orphaned SOPs and masked SOPs should not overlap, something is very wrong."
        )

    # the list of file_ids that need to be deleted from this activity
    # and added to the new one (if given)
    move_list = list(premasked_files) # start with the premasked files
    # The list of sop_instance_uids that have been edited and need to be
    # added to the current activity. TODO: don't forget to update dicom_edit_compare!
    edit_list = []

    # TODO switch this back to files_in_activity!
    # for i, file in enumerate(get_all_files_in_activity(args.activity_id, conn)):
    # all_files_in_current_timepoint = get_all_files_in_timepoint(8430, conn)
    all_files_in_current_timepoint = get_all_files_in_activity(args.activity_id, conn)

    # these files have the post-hashed SOP UIDs
    postmasked_files = get_output_images_to_masked_iecs(conn, args.visual_review_instance_id, function_list)

    # build a map of sop_instance_uid to file tuple for postmasked_files
    postmasked_map = {file.sop_instance_uid: file for file in postmasked_files}

    # remove from all_files_in_current_timepoint any entries that are in
    # premasked_sops (these are pre-hashed UIDs).

    files_to_process = []
    for file in all_files_in_current_timepoint:
        if file.sop_instance_uid not in premasked_sops:
            files_to_process.append(file)
        else:
            # instead of adding it, we want to add the corresponding file from the postmasked_files list
            # the post-masked map is keyed by the hashed SOP Instance UID, not the original one
            hashed_sop_instance_uid = hash_uid(file.sop_instance_uid, TCIA_UID_ROOT)
            if hashed_sop_instance_uid in postmasked_map:
                postmasked_file = postmasked_map[hashed_sop_instance_uid]
                files_to_process.append(postmasked_file)


    for i, file in enumerate(files_to_process):
        ds = None
        edited = False

        if file.sop_instance_uid in premasked_sops:
            # print("This file is in masked sops", file)
            # currently doing nothing, this might change later
            pass

        if file.sop_instance_uid in orphan_sops:
            print(file.file_id, "orphaned")
            edited = True

        # Scan for referencing sequences
        if ds is None:
            ds = pydicom.dcmread(file.storage_path)
            # # For local testing only
            # file_id = file.file_id
            # file_content = get_file_data(file_id)
            # if file_content:
            #     ds = pydicom.dcmread(BytesIO(file_content))
        
        for depth, ele in walk_dataset_for_referencing(ds):
            if (
                ele.value in premasked_sops 
                or ele.value in premasked_series
                or ele.value in orphan_sops
            ):  # only needs changed if we edited it!
                edited = True
                ele.value = hash_uid(ele.value, TCIA_UID_ROOT)
                # class_name = uid.UID(file.media_storage_sop_class).keyword
                print(file.file_id, ele.keyword, ele.value)

        if edited:  # if the file was already edited (or needs to be now)
            # Load the file if we haven't yet
            if ds is None:
                ds = pydicom.dcmread(file.storage_path)

            new_filename = temp_dir + "/" + ds.SOPInstanceUID + ".dcm"

            # Hash series and sop uids
            # If this SOP is in the premasked set, it has already been hashed by Masker, so skip it
            if file.sop_instance_uid not in postmasked_map:
                ds.SeriesInstanceUID = hash_uid(ds.SeriesInstanceUID, TCIA_UID_ROOT)
                ds.SOPInstanceUID = hash_uid(ds.SOPInstanceUID, TCIA_UID_ROOT)

                # Add pre-edit file to move list
                move_list.append(file.file_id)
            else:
                # file has already been edited by Masker, and we don't want
                # to add it twice, so delete it from the postmasked map
                del postmasked_map[file.sop_instance_uid]

            # Add post-edit file to edit list
            edit_list.append(
                (file.file_id, file.sop_instance_uid, ds.SOPInstanceUID, new_filename)
            )  # (old_file_id, old_sop, new_sop, new_filename)

            # Save the updated DICOM file
            ds.save_as(new_filename)

        if i % 100 == 0:
            print(f"Processed {i} files...")

    print("Move list:", len(move_list))
    print("Edit list (files edited by this script):", len(edit_list))
    print("Masked list (files edited by Masker):", len(premasked_sops))

    premasked_report = background.create_report(f"Premasked files import skeleton")
    create_report_from_files(
        premasked_report,
        move_list,
        args.notify,
        f"Pre-masked files from activity {args.activity_id}",
    )

    ## New files that need to be added to the current timepoint
    ## This is all files we just edited, plus the post-mask files
    files_to_add = import_edits(edit_list) + [postmasked_map[f].file_id for f in postmasked_map]

    files_to_remove = move_list

    unedited_files = update_timepoint(
        args.activity_id, args.notify, files_to_remove, files_to_add, conn
    )

    edited_report = background.create_report("Files that were not edited")
    create_report_from_files(
        edited_report,
        unedited_files,
        args.notify,
        f"Files that were not edited in activity {args.activity_id}",
    )

    background.finish("Complete")


if __name__ == "__main__":
    temp_dir_base = os.path.join(Config.get("cache_root"), "edits")
    # # FOR LOCAL TESTING ONLY    
    # temp_dir_base = os.path.join("C:\\data\\cache", "edits")
    with tempfile.TemporaryDirectory(dir=temp_dir_base) as temp_dir:
        sys.exit(main(parse_args(), temp_dir))
