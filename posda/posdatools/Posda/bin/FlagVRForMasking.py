#!/usr/bin/python3 -u
ABOUT="""\
FlagVRForMasking.py
A program for flagging all IECs with a VR for masking 
"""
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.main import printe

from psycopg2.extras import execute_values

import argparse
import sys
from typing import List, Set

def flag_iecs_for_masking(db: Database,
                          iec_list: List[int]) -> None:

    with db.cursor() as cur:
        query = """\
            insert into masking (image_equivalence_class_id) values %s
        """
        execute_values(cur, query, [(iec,) for iec in iec_list])

        query = """\
            insert into masking_history
            values %s
        """
        data = [(iec, 'created', 0) for iec in iec_list]
        execute_values(cur, query, data, template="(%s, %s, now(), %s)")

        cur.connection.commit()

def halt_iec_rendering(db: Database,
                       visual_review_instance_id: int) -> None:
    query = """\
        update image_equivalence_class
        set processing_status = 'Skipped'
        where visual_review_instance_id = %s
        and processing_status = 'ReadyToProcess'
    """
    with db.cursor() as cur:
        cur.execute(query, [visual_review_instance_id])
        cur.connection.commit()
        print(f"Halted rendering for visual_review_instance_id {visual_review_instance_id}")

def get_iecs_in_vr(db, visual_review_instance_id: int) -> Set[int]:
    query = """
        select image_equivalence_class_id
        from image_equivalence_class
        where visual_review_instance_id = %s
    """

    with db.cursor() as cur:
        cur.execute(query, [visual_review_instance_id])
        results = cur.fetchall()

        return {r[0] for r in results}

def main(args):

    background = BackgroundProcess(args.background_id,
                                   args.notify,
                                   args.activity_id)
    background.daemonize()

    print(f"Preparing to flag visual_review_instance_id {args.visual_review_instance_id} for Masking.")

    db = Database("posda_files")

    print("Halting IEC Rendering")
    halt_iec_rendering(db, args.visual_review_instance_id)    

    vr_iecs = get_iecs_in_vr(db, args.visual_review_instance_id)

    if len(vr_iecs) <= 0:
        print("IEC List is empty! Aborting!")
    else:
        print(f"visual_review_instance_id {args.visual_review_instance_id} has {len(vr_iecs)} IECs.")
        background.set_activity_status(
            f"Read IECs from VR, found {len(vr_iecs)}")

        print(f"Flagging {len(vr_iecs)} IECs for masking.")

        flag_iecs_for_masking(db, vr_iecs)

    background.finish("Complete")

def parse_args():
    parser = argparse.ArgumentParser(description=ABOUT)
    parser.add_argument('background_id', help='the background_subprocess_id')
    parser.add_argument(
        'activity_id',
        help='the activity to log the change to'
    )
    parser.add_argument(
        'visual_review_instance_id',
        help='visual_review_instance_id of the VR you want to flag for masking'
    )
    parser.add_argument('notify', help='user to notify when complete')

    return parser.parse_args()


if __name__ == '__main__':
    main(parse_args())
