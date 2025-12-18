#!/usr/bin/env python3
"""
A new version of the ApplyMasks script
"""
import argparse
import hashlib
# import tempfile
import pydicom
import sys
# import os
import csv
from collections import defaultdict
from posda.database import Database
from posda.config import Config
from posda.background.process import BackgroundProcess
from typing import List, Set, Iterator, Tuple
from pydicom.sequence import Sequence
from pydicom.dataset import Dataset
from pydicom import uid
from psycopg2.extras import execute_values
from pprint import pprint

# the real one
TCIA_UID_ROOT = "<!1.3.6.1.4.1.14519.5.2.1>"

TAGS_TO_SCAN = [
    "StudyInstanceUID",
    "SeriesInstanceUID",
    "SOPInstanceUID",
    "ReferencedSOPInstanceUID",
    "MultiFrameSourceSOPInstanceUID",
    "SOPInstanceUIDOfConcatenationSource",
]

# Tags which are considered to contain a UID value we want to test for
UID_KEYWORDS = set(TAGS_TO_SCAN)

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

def walk_dataset(ds: Dataset, depth: int = 0, path: List[str] | None = None, key_path: List[str] | None = None) -> Iterator[Tuple[int, object, List[str], List[str]]]:
    """Traverse a pydicom Dataset recursively, yielding (depth, elem, path, key_path).

    path is a list of tag hex strings like "(0008,0060)"; sequence
    items append an index like "[0]" to distinguish branches.
    key_path is a parallel list of keywords (or tag hex if keyword missing).
    """
    if path is None:
        path = []
    if key_path is None:
        key_path = []
    for elem in ds:
        # Represent this element
        tag_hex = f"({elem.tag.group:04X},{elem.tag.element:04X})"
        keyword = elem.keyword if elem.keyword else tag_hex
        current_path = path + [tag_hex]
        current_key_path = key_path + [keyword]
        if isinstance(elem.value, Sequence):
            for i, item in enumerate(elem.value):
                # Add index component for sequence item
                seq_path = current_path + [f"[{i}]"]
                seq_key_path = current_key_path + ["|"]
                yield from walk_dataset(item, depth + 1, seq_path, seq_key_path)
        elif isinstance(elem.value, Dataset):
            yield from walk_dataset(elem.value, depth + 1, current_path, current_key_path)
        elif elem.tag == (0x7FE0, 0x0010):  # skip PixelData
            continue
        else:
            yield depth, elem, current_path, current_key_path


def walk_dataset_for_referencing(ds: Dataset) -> Iterator[Tuple[int, object, List[str], List[str]]]:
    """
    Walk the dataset and yield only those tags we care about.

    We care about tags that are in UID_KEYWORDS and are NOT at the root
    level (that is, have a depth over 0).
    """
    for depth, elem, path, key_path in walk_dataset(ds):
        if elem.keyword in UID_KEYWORDS and depth > 0:
            yield depth, elem, path, key_path


def hash_uid(uid, uid_root):
    md5 = hashlib.md5(uid.encode())
    new_uid = f"{uid_root}.{int(md5.hexdigest(), 16)}"[:64]
    return new_uid


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
            from dicom_class_iod_requirement req
            join dicom_sop_class dsc 
            on dsc.sop_class_uid = req.sop_class_uid 
            join dicom_class_iod_requirement_tag rt_seq
            on req.tag_full = rt_seq.tag_full
            join sequences seq
            on rt_seq.tag = seq.seq_tag
            join dicom_class_iod_requirement_tag rt_ele
            on req.tag_full = rt_ele.tag_full
            join elements ele
            on rt_ele.tag = ele.ele_tag
            order by req.sop_class_uid, req.tag_full
        """
        )

        for row in cur:
            sop_map[row.sop_class_uid][row.seq_key].add(row.ele_key)

    return sop_map


def get_activity_files(args, conn):
    """
    Returns tuples of (file_id, storage_path, media_storage_sop_class, sop_instance_uid)
    """

    activity_id = args.activity_id

    file_query = """
            with files_in_activity as 
            (
                select file_id
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

    print("CheckLinkages.py running with the following arguments:")
    print(f"Activity ID: {args.activity_id}")

    # print("Will generate edit skeleton for moving pre-masked files")

    print("------------------------------------------")


def create_edit_skeleton(report, notify, activity_id):
    writer = csv.writer(report, lineterminator='\n')
    writer.writerow(
        [
            "series_instance_uid",
            "num_files",
            "op",
            "tag",
            "val1",
            "val2",
            "Operation",
            "edit_description",
            "notify",            
            "activity_id"
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
            None,
            "BackgroundEditTp",  # Operation
            "Edits from Linkage Check",
            notify,
            activity_id
        ]
    )
    # write the detail row
    writer.writerow(
        [
            None,
            None,
            "hash_unhashed_uid",
            None,
            TCIA_UID_ROOT,
            "<>",
            None,
            None,
            None,
            None
        ]
    )    


def create_anomaly_report(report, uid_anomalies):
    writer = csv.writer(report, lineterminator='\n')
    writer.writerow(["type", "uid", "count", "file_ids"])
    for row_a in uid_anomalies:
        writer.writerow(row_a)        


def create_reference_report(report, missing_references):    
    writer = csv.writer(report, lineterminator='\n')
    writer.writerow(["file_id", "modality", "series_instance_uid", "path", "key_path", "category", "referenced_uid", "missing", "note"])
    for file_id, modality, series_instance_uid, path, key_path, category, ref_uid, missing_flag, note in missing_references:
        writer.writerow([file_id, modality, series_instance_uid, path, key_path, category, ref_uid, missing_flag, note])  


def detect_uid_anomalies(file_rows):
    """Analyze UID collections and return anomaly rows plus UID sets."""
    sop_counts = defaultdict(list)
    file_id_by_sop = {}
    series_uids = set()
    study_uids = set()
    for_uids = set()
    for row in file_rows:
        file_id = row.file_id
        sop = row.sop_instance_uid
        series = row.series_instance_uid
        study = row.study_instance_uid
        for_uid = row.for_uid
        if sop:
            if sop not in file_id_by_sop:
                file_id_by_sop[sop] = file_id  # preserve first occurrence
            sop_counts[sop].append(file_id)
        if series:
            series_uids.add(series)
        if study:
            study_uids.add(study)
        if for_uid:
            for_uids.add(for_uid)

    # SOP duplicate detection only
    dup_sop = {k: v for k, v in sop_counts.items() if len(v) > 1}

    # Derive SOP UID set (others already sets)
    sop_uids = set(sop_counts.keys())

    # Cross-category overlaps (require sets)
    sop_series_overlap = sop_uids & series_uids
    sop_study_overlap = sop_uids & study_uids
    sop_for_overlap = sop_uids & for_uids
    series_study_overlap = series_uids & study_uids
    series_for_overlap = series_uids & for_uids
    study_for_overlap = study_uids & for_uids

    # Prepare anomalies report rows: only duplicate_sop plus overlaps
    uid_anomalies = []
    for uid_val, fids in dup_sop.items():
        uid_anomalies.append(("duplicate_sop", uid_val, len(fids), ';'.join(map(str, fids))))

    def add_overlap(label, values):
        for u in values:
            uid_anomalies.append((label, u, 1, ''))

    add_overlap("overlap_sop_series", sop_series_overlap)
    add_overlap("overlap_sop_study", sop_study_overlap)
    add_overlap("overlap_sop_for", sop_for_overlap)
    add_overlap("overlap_series_study", series_study_overlap)
    add_overlap("overlap_series_for", series_for_overlap)
    add_overlap("overlap_study_for", study_for_overlap)

    # Emit summary to stdout
    print(f"Duplicate SOP UID(s): {len(dup_sop)}")
    print(f"Overlaps - SOP/Series: {len(sop_series_overlap)} - SOP/Study: {len(sop_study_overlap)} - SOP/FOR: {len(sop_for_overlap)} - Series/Study: {len(series_study_overlap)} - Series/FOR: {len(series_for_overlap)} - Study/For: {len(study_for_overlap)}")
    print(f"Found {len(file_rows)} File(s), {len(sop_uids)} SOP UID(s), {len(series_uids)} Series UID(s), {len(study_uids)} Study UID(s), {len(for_uids)} Frame of Reference UID(s)")

    return uid_anomalies, sop_uids, series_uids, study_uids, for_uids


def find_missing_references(file_rows, sop_uids, series_uids, study_uids, for_uids):
    """Scan files for referenced UIDs that are absent from collected sets."""
    missing_references = []  # (file_id, tag_keyword, ref_uid)
    for i, file in enumerate(file_rows):
        # if "posda-archive" in file.storage_path:
        #     print("## skipping this posda-archive file!", file.storage_path)
        #     continue
        ds = None

        # Scan for referencing sequences
        if ds is None:
            # For production
            ds = pydicom.dcmread(file.storage_path, stop_before_pixels=True, force=True)
            # # For local testing only
            # file_id = file.file_id
            # file_content = get_file_data(file_id)
            # if file_content:
            #     ds = pydicom.dcmread(BytesIO(file_content), stop_before_pixels=True, force=True)

        if ds is None:
            continue

        for depth, elem, path, key_path in walk_dataset_for_referencing(ds):
            # Only process elements with a string-like UID value
            val = getattr(elem, 'value', None)
            if not isinstance(val, str):
                continue
            # Determine if this referenced UID exists in activity
            exists = False
            category = None
            # For SEG, this tag tends to be a study reference
            if (key_path[0] == "ReferencedStudySequence" and key_path[2] == "ReferencedSOPInstanceUID"):
                category = "study"
                exists = val in study_uids
            # For RT, this tag tends to be a study reference
            elif (key_path[2] == "RTReferencedStudySequence" and key_path[4] == "ReferencedSOPInstanceUID"):                
                category = "study"
                exists = val in study_uids            
            elif elem.keyword in ("ReferencedSOPInstanceUID", "SOPInstanceUID", "MultiFrameSourceSOPInstanceUID", "SOPInstanceUIDOfConcatenationSource"):
                category = "sop"
                exists = val in sop_uids
            elif elem.keyword == "SeriesInstanceUID":
                category = "series"
                exists = val in series_uids
            elif elem.keyword == "StudyInstanceUID":
                category = "study"
                exists = val in study_uids
            # Record missing references (exclude root-level original SOP inside its own file)
            if not exists and category:
                missing_references.append(
                    {
                        "file_id": file.file_id,
                        "modality": file.modality,
                        "series_instance_uid": file.series_instance_uid,
                        "path": f"<{''.join(path)}>",
                        "key_path": f"<{''.join(key_path)}>",
                        "uid": val,
                        "category": category,
                        "note": "UID not present in activity timepoint scope",
                        "missing": True,
                    }
                )
        if i and i % 100 == 0:
            print(f"Scanned {i} files; missing refs so far: {len(missing_references)}")

    return missing_references


def lookup_uids(conn, category, uid_values):
    """Return newest activity/timepoint details for the supplied UIDs of a category."""
    if not uid_values:
        return {}

    queries = {
        "sop": (
            """
            select distinct on (fsc.sop_instance_uid)
                fsc.sop_instance_uid as uid_value,
                at.activity_id,
                at.activity_timepoint_id,
                atf.file_id
            from file_sop_common fsc
            join activity_timepoint_file atf on atf.file_id = fsc.file_id
            join activity_timepoint at on at.activity_timepoint_id = atf.activity_timepoint_id
            where fsc.sop_instance_uid = any(%s)
            order by fsc.sop_instance_uid, at.activity_id desc, at.activity_timepoint_id desc
            """,
        ),
        "series": (
            """
            select distinct on (fs.series_instance_uid)
                fs.series_instance_uid as uid_value,
                at.activity_id,
                at.activity_timepoint_id,
                atf.file_id
            from file_series fs
            join activity_timepoint_file atf on atf.file_id = fs.file_id
            join activity_timepoint at on at.activity_timepoint_id = atf.activity_timepoint_id
            where fs.series_instance_uid = any(%s)
            order by fs.series_instance_uid, at.activity_id desc, at.activity_timepoint_id desc
            """,
        ),
        "study": (
            """
            select distinct on (fst.study_instance_uid)
                fst.study_instance_uid as uid_value,
                at.activity_id,
                at.activity_timepoint_id,
                atf.file_id
            from file_study fst
            join activity_timepoint_file atf on atf.file_id = fst.file_id
            join activity_timepoint at on at.activity_timepoint_id = atf.activity_timepoint_id
            where fst.study_instance_uid = any(%s)
            order by fst.study_instance_uid, at.activity_id desc, at.activity_timepoint_id desc
            """,
        ),
    }

    query = queries.get(category)
    if not query:
        return {}

    cursor = conn.cursor()
    cursor.execute(query[0], (list(uid_values),))
    results = {}
    for row in cursor.fetchall():
        uid_value, activity_id, activity_timepoint_id, file_id = row
        results[(category, uid_value)] = {
            "activity_id": activity_id,
            "activity_timepoint_id": activity_timepoint_id,
            "file_id": file_id,
        }
    cursor.close()
    return results


def annotate_missing_references(conn, missing_references):
    """Augment missing references with latest known locations outside the current scope."""
    if not missing_references:
        return missing_references

    category_to_uids = defaultdict(set)
    for entry in missing_references:
        category = entry.get("category")
        uid_value = entry.get("uid")
        if category and uid_value:
            category_to_uids[category].add(uid_value)

    location_map = {}
    for category, uid_values in category_to_uids.items():
        location_map.update(lookup_uids(conn, category, uid_values))

    for entry in missing_references:
        key = (entry.get("category"), entry.get("uid"))
        location = location_map.get(key)
        if location:
            entry["note"] = (
                f"Found in activity {location['activity_id']} "
                f"timepoint {location['activity_timepoint_id']} "
                f"file {location['file_id']}"
            )
            entry["missing"] = False
        else:
            entry.setdefault("missing", True)

    return missing_references


def main2(args, background):
    generate_arg_report(args)

    conn = Database("posda_files")

    # Map of SOP Class UIDs to sequences that need hashed
    # sop_map = load_map()

    file_rows = get_activity_files(args, conn)
    uid_anomalies, sop_uids, series_uids, study_uids, for_uids = detect_uid_anomalies(file_rows)
    anomaly_report = background.create_report("UID_Anomalies")
    create_anomaly_report(anomaly_report, uid_anomalies)

    missing_references = find_missing_references(file_rows, sop_uids, series_uids, study_uids, for_uids)
    missing_references = annotate_missing_references(conn, missing_references)
    reference_rows = [
        (
            entry["file_id"],
            entry["modality"],
            entry["series_instance_uid"],
            entry["path"],
            entry["key_path"],
            entry["category"],
            entry["uid"],
            "X" if entry.get("missing") else "",
            entry["note"],
        )
        for entry in missing_references
    ]
    print(f"Found {len(reference_rows)} Missing References")   
    reference_report = background.create_report("Missing_References")
    create_reference_report(reference_report, reference_rows)

    edit_skeleton = background.create_report("Edit_Skeleton")
    create_edit_skeleton(edit_skeleton, args.notify, args.activity_id)

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
