#!/usr/bin/env python3

import querylib
import sys
import os
from pprint import pprint
from psycopg2 import IntegrityError


files = []
try:
    directory = sys.argv[1]
except IndexError:
    print(f"Usage: {sys.argv[0]} DIRECTORY | FILE")
    print()
    print("If a directory is given, all files in it are processed.")
    sys.exit(1)


if directory.lower().endswith('.sql'):
    # single-file mode
    files.append(directory)
    directory = ''
else:
    for filename in os.listdir(directory):
        if filename.lower().endswith(".sql"):
            files.append(filename)

# print(f"Processing {len(files)} files.")

conn = querylib.connect()
cur = conn.cursor()

for f in files:
    with open(os.path.join(directory, f)) as inf:
        query = querylib.parse_query_string(inf.read())
        print(cur.mogrify("""
            insert into queries
            values (%(name)s, %(query)s, %(args)s, 
                    %(columns)s, %(tags)s, %(schema)s, %(description)s)
        """, query).decode(), end=';\n')

conn.close()
