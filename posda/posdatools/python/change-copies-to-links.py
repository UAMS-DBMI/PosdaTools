#!/usr/bin/env python3

from datetime import datetime
from pprint import pprint

import json
import os
import sys
import hashlib
import psycopg2

db_parms = {
    "user": "postgres",
    "dbname": "posda_files",
    # "host": "tcia-utilities"
    "host": "localhost"
}

conn = None

skipped_count = 0
linked_count = 0
error_count = 0


def spinning_cursor():
    while True:
        for cursor in '|/-\\':
            yield cursor

spinner = spinning_cursor()

def spin():
    sys.stdout.write(next(spinner))
    sys.stdout.flush()
    sys.stdout.write('\b')


def is_dicom_file(full_path):
    """Attempt to guess if a file is a DICOM"""

    for ext in ['.pinfo',
                '.info',
                '.txt']:

        if full_path.endswith(ext):
            return False

    return True

def main(parms, path):
    global skipped_count, error_count, linked_count

    i = 0
    print("Scanning {} and replacing any copies with links...".format(path))
    for root, dirs, files in os.walk(path):
        for file in files:
            if file:
                i += 1
                if i % 100 == 0:
                    spin()
                if i % 1000 == 0:
                    print("Processed {} files so far...".format(i))

                full_path = os.path.join(root, file)
                if is_dicom_file(full_path):
                    md5 = hashlib.md5(open(full_path, 'rb').read()).hexdigest()
                    main2(full_path, md5)


    print("Finished processing {} files!".format(i))
    print("Successfully linked {} files.".format(linked_count))
    print("Skipped {} because they were already linked correctly!".format(skipped_count))
    print("Errors encountered on {} files :(".format(error_count))


def main2(root, md5):
    global skipped_count, linked_count, error_count

    cur = conn.cursor()

    query = """
        select root_path, rel_path
        from file
        natural join file_location
        natural join file_storage_root
        where digest = '{}'
    """.format(md5)

    cur.execute(query)

    try:
        root_path, rel_path = cur.fetchone()
        orig_path = os.path.join(root_path, rel_path)
    except TypeError:
        print("No original found for: {}".format(root))
        error_count += 1
        return


    if not os.path.exists(orig_path):
        print("Original does not exist: {}".format(orig_path))
        error_count += 1
        return

    if os.lstat(orig_path).st_ino == os.lstat(root).st_ino:
        skipped_count += 1
        return

    os.remove(root)
    os.link(orig_path, root)
    print("{} => {}".format(orig_path, root))
    linked_count += 1


root = '/cache/posda/Data/HierarchicalExtractions/data/'

conn = psycopg2.connect(
    "dbname={dbname} user={user} host={host}".format(**db_parms))

main(db_parms, root)

conn.close()
