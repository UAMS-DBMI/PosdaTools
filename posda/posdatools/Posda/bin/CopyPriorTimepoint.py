#!/usr/bin/python3 -u
ABOUT="""\
A program to copy a prior timepoint into a new timepoint 
in the current activity.

Expects nothing on STDIN.

"""

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from psycopg2.extras import execute_values

import argparse
from typing import List

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

def get_files_in_timepoint(db, timepoint_id: int) -> List[int]:
    query = """
        select file_id
        from activity_timepoint_file
        where activity_timepoint_id = %s
    """

    file_ids = []
    with db.cursor() as cur:
        cur.execute(query, [timepoint_id])
        results = cur.fetchall()

        return [r[0] for r in results]

def main(args):
    background = BackgroundProcess(args.background_id,
                                   args.notify,
                                   args.activity_id)
    background.daemonize()

    print(f"Preparing to copy activity_timepoint_id {args.old_timepoint_id} "
          f"to activity_id {args.activity_id}.")

    db = Database("posda_files")

    old_tp_files = get_files_in_timepoint(db, args.old_timepoint_id)

    print(f"Old timepoint has {len(old_tp_files)} files.")
    background.set_activity_status(
        f"Read files from old tp, found {len(old_tp_files)}")

    new_tp_id = create_activity_timepoint(args, db)

    print(f"New activity_timepoint_id is {new_tp_id}")
    insert_files_into_timepoint(db, new_tp_id, old_tp_files)

    background.finish("Complete")

def parse_args():
    parser = argparse.ArgumentParser(description=ABOUT)
    parser.add_argument('background_id', help='the background_subprocess_id')
    parser.add_argument(
        'activity_id',
        help='the activity to create the new timepoint in'
    )
    parser.add_argument(
        'old_timepoint_id',
        help='activity_timepoint_id of the timepoint you want to copy'
    )
    parser.add_argument('notify', help='user to notify when complete')

    return parser.parse_args()


if __name__ == '__main__':
    main(parse_args())
