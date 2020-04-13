#!/usr/bin/python3 -u

import json
import time
import os
import hashlib
import redis
from typing import NamedTuple

import requests
import psycopg2

USER=os.environ['EXODUS_USER']
PASS=os.environ['EXODUS_PASS']
RETRY_COUNT=int(os.environ['EXODUS_RETRY_COUNT'])
PSQL_DB_NAME=os.environ['EXODUS_PSQL_DB_NAME']

class SubmitFailedError(RuntimeError): pass

class File(NamedTuple):
    export_event_id: int
    import_event_id: int
    file_id: int
    file_path: str
    base_url: str

def main_loop(redis_db, psql_db):

    while True:
        sr = redis_db.brpop("posda_to_posda_transfer", 5)
        if sr is None:
            continue

        _, value = sr
        file = File(*json.loads(value))

        try:
            submit_file(file)
            update_success(psql_db, file.file_id, file.export_event_id)
            last_failed = True
        except SubmitFailedError as e:
            # probably should put this onto a failed-file list now?
            print(e)
            insert_errors(psql_db, file.file_id, file.export_event_id, e)

def update_success(psql_db, file_id, export_event_id):
    try:
        psql_db.execute("""
            update file_export set
              when_transferred = now(),
              transfer_status = 'success'
            where export_event_id = %s
              and file_id = %s
        """, [export_event_id, file_id])
    except Exception as e:
        print(e)

def insert_errors(psql_db, file_id, export_event_id, errors):
    transfer_status_id = None
    try:
        (transfer_status_id) = psql_db.execute("""
            insert into transfer_status
            values (default, %s)
            returning transfer_status_id
        """, [str(errors)])
    except psycopg2.IntegrityError:
        (transfer_status_id) = psql_db.execute("""
            select transfer_status_id
            from transfer_status
            where transfer_status_message = %s
        """, [str(errors)])
    if transfer_status_id is None:
        print("Unable to create or get transfer_status_id for following error")
        print(str(errors))
    try:
        psql_db.execute("""
            update file_export set
              when_transferred = now(),
              transfer_status = 'failed permanent',
              transfer_status_id = %s
            where export_event_id = %s
              and file_id = %s
        """, [transfer_status_id, export_event_id, file_id])
    except Exception as e:
        print(e)

def md5sum(filename):
    md5 = hashlib.md5()
    with open(filename, 'rb') as f:
        for chunk in iter(lambda: f.read(128 * md5.block_size), b''):
            md5.update(chunk)
    return md5.hexdigest()

def submit_file(file):
    """Submit the file, try several times before giving up"""
    errors = []
    # for i in range(RETRY_COUNT):
    try:
        params = {'import_event_id': file.import_event_id,
                  'digest': md5sum(file.file_path)}
        return _submit_file(file.file_id, file.file_path, file.base_url, params)
    except SubmitFailedError as e:
        errors.append(e)
        # break
    except IOError as e:
        errors.append(e)

    raise SubmitFailedError(("Failed to submit the file; error details follow", file, errors))


def _submit_file(file_id, file_path, base_url, params):
    infile = open(file_path, "rb")
    req = requests.put(base_url + "/papi/v1/import/file", params=params, data=infile)
    infile.close()

    if req.status_code == 200:
        print(file_id)
        return
    else:
        raise SubmitFailedError((req.status_code, req.content))

def main():
    print("exodus, starting up...")

    redis_db = redis.StrictRedis(host="redis", db=0)
    print("connected to redis")

    psql_db_conn = psycopg2.connect(dbname=PSQL_DB_NAME)
    psql_db_conn.autocommit = True
    psql_db_cur = psql_db_conn.cursor()
    print("connected to postgres")

    main_loop(redis_db, psql_db_cur)


if __name__ == "__main__":
    main()
