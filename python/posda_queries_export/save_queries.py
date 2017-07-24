#!/usr/bin/env python3.6

import querylib
import sys
import os
from pprint import pprint
from psycopg2 import IntegrityError


files = []
directory = sys.argv[1]

if directory.lower().endswith('.sql'):
    # single-file mode
    files.append(directory)
    directory = ''
else:
    for filename in os.listdir(directory):
        if filename.lower().endswith(".sql"):
            files.append(filename)

print(f"Processing {len(files)} files.")

conn = querylib.connect()
cur = conn.cursor()

for f in files:
    with open(os.path.join(directory, f)) as inf:
        query = querylib.parse_query_string(inf.read())
        # TODO: once upgraded to psql 9.5+ this can be changed to UPSERT
        try:
            cur.execute("""
                insert into queries
                values (%(name)s, %(query)s, %(args)s, 
                        %(columns)s, %(tags)s, %(schema)s, %(description)s)
            """, query)
            print(f"Added new query: {query['name']}")
        except IntegrityError: # assume this means it already existed
            conn.rollback()
            cur.execute("""
                update queries
                set query =  %(query)s, 
                    args = %(args)s, 
                    columns = %(columns)s, 
                    tags = %(tags)s, 
                    schema = %(schema)s, 
                    description = %(description)s
                where name = %(name)s
            """, query)
            print(f"Updated existing query: {query['name']}")

        conn.commit()

conn.close()
