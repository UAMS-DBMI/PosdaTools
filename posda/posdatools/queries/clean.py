#!/usr/bin/env python3
HELP="""
Clean orphaned queries from the database. That is, delete
queries from the database that exist in the database but 
do not exist in the given directory.

A report will be prepared summarizing what will be removed
and the user will be given a chance to confirm before any
permanent action is taken.
"""


import querylib
import os
import sys
import argparse

def parse_args():
    parser = argparse.ArgumentParser(description=HELP)
    parser.add_argument('--path',
                        default="sql/",
                        help='File or directory to export to (default: ./sql)')

    return parser.parse_args()

def list_queries_in_dir(directory):
    files = []
    for filename in os.listdir(directory):
        if filename.lower().endswith(".sql"):
            files.append(os.path.splitext(filename)[0])

    return files

def main(args):

    # collect list of all queries in the directory
    queries_in_dir = set(list_queries_in_dir(args.path))

    # collect list of all queries in the database
    queries_in_db = set([name for name, *rest in querylib.list_queries()])

    # prepare difference
    to_delete = sorted(list(queries_in_db.difference(queries_in_dir)))
    to_del_num = len(to_delete)

    if to_del_num <= 0:
        print("Did not find any orphaned queries!")
        print(f"There are {len(queries_in_db)} queries in the database, and "
              f"{len(queries_in_dir)} queries in the directory '{args.path}'.")
        print("All query names match exactly.")
        sys.exit(0)

    # present report
    print(f"Found {to_del_num} orphaned queries.")
    print("Here are the first 10:")
    for q in to_delete[:10]:
        print(f"\t{q}")

    if to_del_num > 10:
        print("Here are the last 10:")
        for q in to_delete[-10:]:
            print(f"\t{q}")

    # ensure they are sure
    print(f"Are you very very sure you want to delete these {to_del_num} "
          "queries from the database?")
    user_response = input("Type YES to continue: ")
    if user_response != 'YES':
        print("Aborting!")
        sys.exit(1)

    # perform delete
    conn = querylib.connect()
    cur = conn.cursor()

    for query in to_delete:
        cur.execute("""
            delete from queries
            where name = %s
        """, [query])
        print(f"Deleted query: {query}")

    conn.commit()
    conn.close()

if __name__ == '__main__':
    args = parse_args()
    main(args)
