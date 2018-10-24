#!/usr/bin/env python3.6

from posda.queries import Database
import csv

db = Database("posda_files")


def isa_csv(filename):
    ret = True
    with open(filename, 'r') as csv_fileh:
        try:
            dialect = csv.Sniffer().sniff(csv_fileh.read(1024 * 3))

            if dialect.delimiter != ',':
                ret = False

            if not (dialect.lineterminator == '\n' 
                    or dialect.lineterminator == '\r\n'):
                ret = False

        except: # catch everything, because we don't want to crash here
            ret = False

    return ret
with db as conn:
    select_cur = conn.cursor()
    update_cur = conn.cursor()
    select_cur.execute("""
        select
            file_id,
            root_path || '/' || rel_path as path
        from file 
        natural join file_location
        natural join file_storage_root
        where file_type = 'ASCII text'
    """)
    for file_id, path in select_cur:
        if isa_csv(path):
            print("Fixing ", file_id)
            update_cur.execute("update file set file_type = 'CSV' where file_id = %s", [file_id])

