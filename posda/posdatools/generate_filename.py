#!/usr/bin/env python3

from hashlib import md5
import argparse
import os

import psycopg2

def gen_filename(sop_instance_uid):
    """Generate the storage path filename for the given sop"""

    digest = md5(sop_instance_uid.encode()).hexdigest()

    return os.path.join(
        digest[:2],
        digest[2:4],
        digest[4:6],
        digest
    )

def series(root_path, ext, series):
    conn = psycopg2.connect(dbname='posda_files')
    cur = conn.cursor()
    cur.execute("""\
        select sop_instance_uid
        from file_series
        natural join file_sop_common
        where series_instance_uid = %s
    """, [series])

    for sop, in cur:
        path = os.path.join(root_path, gen_filename(sop))
        print(path + ext)

    conn.close()

def sop_instance(root_path, ext, sop):
    path = os.path.join(root_path, gen_filename(sop))
    print(path + ext)

def parse_args():
    parser = argparse.ArgumentParser(
        description='',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        'SOP',
        help='A SOP Instance UID or Series Instance UID ')
    parser.add_argument(
        '--series',
        action="store_true",
        help='If given, treat SOP as a Series Instance UID')
    parser.add_argument(
        '--root_path',
        default="/nas/public/storage-from-posda",
        help='The root path to print in front of the filenames')
    parser.add_argument(
        '--ext',
        default=".dcm",
        help='The extension to print at the end of filenames')
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()

    if args.series:
        series(args.root_path, args.ext, args.SOP)
    else:
        sop_instance(args.root_path, args.ext, args.SOP)
