#!/usr/bin/python3 -u

import json
import time
import os
import hashlib

import requests
import psycopg2


EXPORT_ID=os.environ['EXODUS_EXPORT_ID']
USER=os.environ['EXODUS_USER']
PASS=os.environ['EXODUS_PASS']
RETRY_COUNT=int(os.environ['EXODUS_RETRY_COUNT'])
PSQL_DB_NAME=os.environ['EXODUS_PSQL_DB_NAME']
IMPORT_IDS={}

class SubmitFailedError(RuntimeError): pass


def main_loop(psql_db):
    global IMPORT_IDS
    sleep_time = 1

    while True:
        last_failed = True
        (export_event_id, base_url, configuration) = psql_db.execute("""
            select export_event_id, base_url, configuration
            from export_event
            natural join export_destination
            where export_status = 'transfering'
            and protocol = 'posda'
            order by export_event_id
            limit 1
        """)
        print("Uploading file from {} export event".format(export_event_id))
        print(configuration)

        (file_id, file_path) = psql_db.execute("""
            select file_id, root_path || '/' || rel_path as path
            from file_export
            natural join file_location
            natural join file_storage_root
            where export_event_id = 1
            and transfer_status = 'pending'
            limit 1
        """)

        print("Uploading file {} from {}".format(file_id, file_path))

        if export_event_id not in IMPORT_IDS:
            create_import_event(psql_db, base_url, configuration, export_event_id)

        configuration['import_event_id'] = IMPORT_IDS[export_event_id]

        try:
            submit_file(file_id, file_path, base_url, configuration)
            update_success(psql_db, file_id, export_event_id)
            last_failed = True
        except SubmitFailedError as e:
            # probably should put this onto a failed-file list now?
            print(e)
            insert_errors(psql_db, file_id, export_event_id, e)

            
        if last_failed:
            sleep(sleep_time)
            if sleep_time < 30:
                sleep_time += 1
        else:
            sleep_time = 1

def create_import_event(psql_db, base_url, configuration, export_event_id):
    global IMPORT_IDS
    headers = configuration.copy()
    headers['source'] = "External posda->posda transfer"
    req = requests.post(base_url + "/v1/import/event", headers=headers)
    IMPORT_IDS[export_event_id] = req.json()['import_event_id']

def update_success(psql_db, file_id, export_event_id):
    try:
        psql_db.execute("""
            update file_export set
              when_transferred = NOW()
              and transfer_status = 'success'
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
        """, [str(error))
    except psycopg2.IntegrityError:
        (transfer_status_id) = psql_db.execute("""
            select transfer_status_id
            from transfer_status
            where transfer_status_message = %s
        """, [str(error))
    if transfer_status_id is None:
        print "Unable to create or get transfer_status_id for following error"
        print(e)
    try:
        psql_db.execute("""
            update file_export set
              when_transferred = NOW()
              and transfer_status = 'failed permanent'
              and transfer_status_id = %s
            where export_event_id = %s
              and file_id = %s
        """, [transfer_status_id, export_event_id, file_id])
    except Exception as e:
        print(e)

def submit_file(file_id, file_path, base_url, configuration):
    """Submit the file, try several times before giving up"""
    errors = []
    for i in range(RETRY_COUNT):
        try:
            files = {'file': open(file_path, 'rb')}
            headers = configuration.copy()
            md5 = hashlib.md5()
            md5.update(files['file'])
            headers['digest']= md5.hexdigest()
            return _submit_file(file_id, file_path, base_url, headers)
        except SubmitFailedError as e:
            errors.append(e)
            break
        except IOError as e:
            errors.append(e)

    raise SubmitFailedError(("Failed to submit the file; error details follow", f, errors))


def _submit_file(file_id, files, base_url, headers):
    req = requests.post(base_url + "/v1/import/file", headers=headers, files=files)

    if req.status_code == 200:
        print(file_id)
        return
    else:
        raise SubmitFailedError((req.status_code, req.content))

def main():
    print("exodus, starting up...")

    psql_db_conn = psycopg2.connect(dbname=PSQL_DB_NAME)
    psql_db_conn.autocommit = True
    psql_db_cur = psql_db_conn.cursor()
    print("connected to postgres")

    main_loop(psql_db_cur)


if __name__ == "__main__":
    main()
