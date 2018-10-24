#!/usr/bin/env python3

import sys
from querylib import get_query_as_string

if len(sys.argv) < 2:
  print(f"Usage: {sys.argv[0]} QUERY_NAME")
  sys.exit(1)


query_name = sys.argv[1]

try:
    print(get_query_as_string(query_name))
except KeyError:
    print(f"Query not found: {query_name}")
