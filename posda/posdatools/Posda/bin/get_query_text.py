#!/usr/bin/env python3

import sys
import psycopg2

if len(sys.argv) < 2:
  print(f"Usage: {sys.argv[0]} QUERY_NAME")
  sys.exit(1)


def quote(text):
  return '\n'.join([f"-- {line}" for line in text.split('\n')])

query_name = sys.argv[1]

conn = psycopg2.connect("dbname=posda_files")
cur = conn.cursor()

cur.execute("""
  select *
  from queries
  where name = %s
""", [query_name])

for row in cur:
  name, query, args, columns, tags, schema, description = row
  print(quote(f"Name: {name}\n"
              f"Schema: {schema}\n"
              f"Args: {args}\n"
              f"Tags: {tags}"))

  print()
  print(query)

if cur.rowcount < 1:
  print(f"Query not found: {query_name}")

conn.close()
