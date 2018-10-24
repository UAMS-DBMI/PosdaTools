#!/usr/bin/env python3

import sys
import querylib

def usage():
    print(f"""Usage: {sys.argv[0]} [FIELDS]

Where FIELDS is any combination of the following fields:
  (a) args
  (c) columns
  (t) tags
  (s) schema

The query name is always printed.

Example:
  {sys.argv[0]} act
Would print the fields: Name, Args, Columns, Tags

All printed fields are seperated by a single space. Pipe the results
to 'column -t' if you want to see a pretty table.
""")

    sys.exit(0)

def flatten(things):
    if things is None or len(things) == 0:
        return 'None'
    return ','.join(things)

if len(sys.argv) > 2:
    usage()

if len(sys.argv) < 2:
    print("Printing only names; see --help for usage info", file=sys.stderr)
    arg1 = ''
else:
    arg1 = sys.argv[1]

if arg1 == '--help':
    usage()

fields = sorted(arg1.lower())

for row in querylib.list_queries():
    name, args, columns, tags, schema, description = row
    printable = [i for i in [
        name,
        flatten(args) if 'a' in fields else None,
        flatten(columns) if 'c' in fields else None,
        flatten(tags) if 't' in fields else None,
        schema if 's' in fields else None,
    ] if i is not None]
    print(' '.join(printable))
