#!/usr/bin/env python3

OUT = "output"

import querylib
import os
import sys

try:
    OUT = sys.argv[1]
except IndexError:
    print(f"Usage: {sys.argv[0]} OUTPUT_DIR")
    sys.exit(1)

# querylib.DSN = "postgres://tcia-utilities/N_posda_queries"
# querylib.DSN = "postgres://localhost/posda_queries"

conn = querylib.connect()
cur = conn.cursor()

cur.execute("select name from queries")
for name, in cur:
    path = os.path.join(OUT, name + ".sql")
    # print(querylib.get_query_as_string(name))
    with open(path, "w") as outfile:
        outfile.write(querylib.get_query_as_string(name))

conn.close()
