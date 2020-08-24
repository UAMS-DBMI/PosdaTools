#!/usr/bin/env python3


import querylib
import os
import sys
import argparse

def parse_args():
    parser = argparse.ArgumentParser(
        description="Export a query from the database "
                    "into a .sql file, or export all queries into a "
                    "directory. The query name is chosen based on the "
                    "destination filename. Foo.sql will export a query "
                    "named Food."
    )
    parser.add_argument('PATH', help='File or directory to export to')
    parser.add_argument('--all', action='store_true', 
                        help='If set, export all queries. Implies '
                        'PATH will be a directory')

    return parser.parse_args()

def main(args):
    conn = querylib.connect()

    if args.all:
        export_all(conn, args.PATH)
    else:
        export_one(conn, args)

    conn.close()

def export_all(conn, output_path):
    cur = conn.cursor()

    cur.execute("select name from queries")
    count = 0
    for name, in cur:
        count = count + 1
        path = os.path.join(output_path, name + ".sql")
        with open(path, "w") as outfile:
            outfile.write(querylib.get_query_as_string(name))

    print(f"Exported {count} queries into {output_path}")

def export_one(conn, args):
    filename = os.path.basename(args.PATH)
    query_name, ext = os.path.splitext(filename)
    assert ext == '.sql', "Can only export to a .sql file!"


    with open(args.PATH, "w") as outfile:
        outfile.write(querylib.get_query_as_string(query_name))

if __name__ == '__main__':
    args = parse_args()
    main(args)
