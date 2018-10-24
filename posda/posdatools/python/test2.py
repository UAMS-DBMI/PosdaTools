#!/usr/bin/env python3

from datetime import datetime
from pprint import pprint
import json
import psycopg2

import posda.main

def json_serial(obj):
    """JSON serializer for objects not serializable by default json code"""

    if isinstance(obj, datetime):
        serial = obj.isoformat()
        return serial
    raise TypeError("Type not serializable")

def main(parms):
    conn = psycopg2.connect(
        "dbname={dbname} user={user} host={host}".format(**parms['database']))

    cur = conn.cursor()

    query = """
        select
          minute,
          max(files_in_db_backlog) as max_db_backlog,
          max(dirs_in_receive_backlog) as max_dirs_in_backlog,
          count(*)
        from (
          select 
            files_in_db_backlog,
            dirs_in_receive_backlog,
            at,
            date_trunc('minute', at) as minute
          from app_measurement
          where at > now() - interval '1' day
        ) a
        group by minute
        order by minute
    """

    cur.execute(query)

    rows = cur.fetchall()

    print(json.dumps(rows, default=json_serial))

    conn.close()

parms = posda.main.get_parameters()
main(parms)
