import sys
import psycopg2

CONNECTION = None
DSN="dbname=posda_queries"

def connect():
    global CONNECTION
    if CONNECTION is None:
        CONNECTION = psycopg2.connect(DSN)

    return CONNECTION

def quote(text):
    return '\n'.join([f"-- {line}" for line in text.split('\n')])

def get_query_as_string(query_name):
    ret = []

    conn = connect()
    cur = conn.cursor()

    cur.execute("""
      select *
      from queries
      where name = %s
    """, [query_name])

    for row in cur:
        name, query, args, columns, tags, schema, description = row
        ret.append(quote(f"Name: {name}\n"
                          f"Schema: {schema}\n"
                          f"Columns: {columns}\n"
                          f"Args: {args}\n"
                          f"Tags: {tags}\n"
                          f"Description: {description}"))

        ret.append('')
        ret.append(query)

    if cur.rowcount < 1:
        raise KeyError("Query not found: " + query_name)

    return '\n'.join(ret)


def _parse_control_line(line, query):
    if line.startswith("-- Name: "):
        query["name"] = line[9:]
    elif line.startswith("-- Schema: "):
        query["schema"] = line[11:]
    elif line.startswith("-- Columns: "):
        query["columns"] = line[12:]
    elif line.startswith("-- Args: "):
        query["args"] = line[9:]
    elif line.startswith("-- Tags: "):
        query["tags"] = line[9:]
    elif line.startswith("-- Description: "):
        query["description"] = [line[16:]]
    else:
        query["description"].append(line[3:])


def parse_query_string(query_string):
    control_lines = 0
    query_lines = 0
    query = {"query":[],
             "columns": "None",
             "description": "None",
             "args": "None",
             "tags": "None"}

    try:
        for line in query_string.split('\n'):
            if line.startswith("-- "):
                control_lines += 1
                _parse_control_line(line, query)
            else:
                query_lines += 1
                if query_lines != 1: # skip the first line, it's padding
                    query["query"].append(line)
    except:
        raise RuntimeError("Failed to parse as a Query")

    # magicify it
    try:
        query["columns"] = eval(query["columns"])
        query["args"] = eval(query["args"])
        query["tags"] = eval(query["tags"])
        query["description"] = '\n'.join(query["description"])
        query["query"] = '\n'.join(query["query"])
    except:
        raise RuntimeError("Failed to convert to Query object")

    return query
