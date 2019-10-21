#!/usr/bin/env python
import os
import json

import psycopg2
import redis

from evil import evil_eval

from fire import Fire



def resend_to_public(current_invoc_id, new_invoc_id, limit=None):
    redis_db = redis.StrictRedis(host="tcia-posda-rh-2", db=0)
    conn = psycopg2.connect(dbname="posda_files")




    cur = conn.cursor()

    cur.execute("""\
    select * from public_copy_status
    where success = false
    and subprocess_invocation_id = %s
    """, [current_invoc_id])

    for i, row in enumerate(cur):
        invoc_id, file_id, success, error = row
        _, file, errors = evil_eval(error)
        # print(file)
        # print(os.stat(file.filename))
        invoc_id, file_id, coll, site, site_id, batch, filename = file 
        t = [new_invoc_id, file_id, coll, site, site_id, batch, filename]
        print(t)
        redis_db.lpush("submission_required", json.dumps(t))

        if limit is not None and i >= limit:
            break

    conn.close()

if __name__ == '__main__':
    Fire(resend_to_public)
