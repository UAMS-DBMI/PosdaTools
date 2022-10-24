#!/usr/bin/python3 -u
ABOUT="""\
Adds all files from the timepoints supplied
on STDIN to the activity supplied as a parameter.

Expects lines on STDIN of the form:
<activity_timepoint_id>

"""

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from psycopg2.extras import execute_values

import sys
import argparse
from typing import List, Set

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
                "CopyPriorTimepoint.py",
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

def main(args):
    # read lines from stdin, into a set (comprehension)
    try:
        input_lines = {int(line) for line in sys.stdin}
    except ValueError:
        raise RuntimeError("Error interpreting input! "
                           "Did you supply activity_timepoint_ids "
                           "or something else?")

    print(f"Read {len(input_lines)} lines from STDIN.")

    background = BackgroundProcess(args.background_id,
                                   args.notify,
                                   args.activity_id)
    background.daemonize()

    print(f"Preparing to consolidate {len(input_lines)} activities "
          f"into activity_id {args.activity_id}.")

    db = Database("posda_files")

    main_timepoint = get_latest_timepoint(db, args.activity_id)
    all_files = get_files_in_timepoint(db, main_timepoint)

    for timepoint in input_lines:
        tp_files = get_files_in_timepoint(db, timepoint)
        all_files.update(tp_files)

    print(f"Found {len(all_files)} total files to consolidate.")
    background.set_activity_status(
        f"Found {len(all_files)} total files to consolidate.")

    new_tp_id = create_activity_timepoint(args, db)

    print(f"New activity_timepoint_id is {new_tp_id}")
    insert_files_into_timepoint(db, new_tp_id, all_files)

    background.finish("Complete")

def parse_args():
    parser = argparse.ArgumentParser(description=ABOUT)
    parser.add_argument('background_id', help='the background_subprocess_id')
    parser.add_argument(
        'activity_id',
        help='the activity to create the new timepoint in'
    )
    parser.add_argument('notify', help='user to notify when complete')

    return parser.parse_args()


if __name__ == '__main__':
    main(parse_args())
