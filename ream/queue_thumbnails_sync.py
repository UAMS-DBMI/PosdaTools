#!/usr/bin/python3 -u

import json
import time
import os
import shutil
from typing import NamedTuple
import hashlib
import redis

import requests
import psycopg2
from fire import Fire
from rich.progress import track
from rich import print


class LoginFailedError(RuntimeError): pass
class LoginExpiredError(RuntimeError): pass
class SubmitFailedError(RuntimeError): pass


try:
    URL=os.environ['REAM_URL']
    USER=os.environ['REAM_USER']
    PASS=os.environ['REAM_PASS']
    CLIENTID=os.environ['REAM_CLIENTID']
    CLIENTSECRET=os.environ['REAM_CLIENTSECRET']
    RETRY_COUNT=int(os.environ['REAM_RETRY_COUNT'])
    PSQL_DB_NAME=os.environ['REAM_PSQL_DB_NAME']
except KeyError:
    raise RuntimeError("You need to load the ream.env file first, "
                       "so I know where to connect")
    

BASE_DIR=None
TOKEN=None
DRY=False


class File(NamedTuple):
    subprocess_invocation_id: int
    file_id: int
    collection: str
    site: str
    site_id: int
    batch: int
    filename: str


def main_loop(redis_db, psql_db):
    while True:
        sr = redis_db.brpop("submission_required", 5)
        if sr is None:
            continue

        _, value = sr
        file = File(*json.loads(value))
        try:
            submit_file(file)
            set_file_status(psql_db, file, success=True)
        except SubmitFailedError as e:
            # probably should put this onto a failed-file list now?
            print(e)
            set_file_status(psql_db, file, success=False, error=e)

def set_file_status(psql_db, file, success=True, error=None):
    try:
        psql_db.execute("""
            insert into public_copy_status
            values (%s, %s, %s, %s)
        """, [file.subprocess_invocation_id, file.file_id, success, str(error)])
    except Exception as e:
        print(e)

def submit_file(f):
    """Submit the file, try several times before giving up"""
    global TOKEN

    errors = []
    for i in range(RETRY_COUNT):
        try:
            return _submit_file(f)
        except SubmitFailedError as e:
            errors.append(e)
        except LoginExpiredError:
            TOKEN = login_to_api()

    raise SubmitFailedError(("Failed to submit the file; error details follow", f, errors))


def _submit_file(f):
    payload = {'project': f.collection,
               'siteName': f.site,
               'siteID': f.site_id,
               'batch': f.batch,
               'uri': f.filename,
               }
    headers = {
        "Authorization": "Bearer {}".format(TOKEN),
    }
    req = requests.post(URL + "/nbia-api/services/submitDICOM", headers=headers, data=payload)

    if req.status_code == 200:
        print(f.filename)
        return
    elif req.status_code == 401:
        # indicates an acess error, generally an expired token
        message = req.json()
        if message['error'] == "invalid_token":
            raise LoginExpiredError()
        else:
            raise SubmitFailedError(req.content)
    else:
        raise SubmitFailedError((req.status_code, req.content))

def login_to_api():
    payload = {'username': USER,
               'password': PASS,
               'client_id': CLIENTID,
               'client_secret': CLIENTSECRET,
               'grant_type': 'password',
               }
    req = requests.post(URL + "/nbia-api/oauth/token", data=payload)

    if req.status_code == 200:
        obj = req.json()
        return obj['access_token']
    else:
        raise LoginFailedError(req.content)

def login_or_die():
    for i in range(10):
        try:
            return login_to_api()
        except LoginFailedError as e:
            print(e)
            time.sleep(1)

    raise LoginFailedError("Login failed too many times, see previous errors!")


def files_from_series(cursor, series):
    cursor.execute("""
        select storage_path(file_id), sop_instance_uid
        from file_sop_common
        natural join file_series
        where series_instance_uid = %s
    """, [series])

    return [
        (sop, path)
        for path, sop in cursor
    ]

def make_filename_from_sop(sop):
    md5 = hashlib.md5()
    md5.update(sop.encode())
    digest = md5.hexdigest()

    path = "{}/{}/{}/{}.dcm".format(
        digest[:2],
        digest[2:4],
        digest[4:6],
        digest
    )

    return BASE_DIR + '/' + path

def copy_sop_into_place(sop, current_filename):
    new_filename = make_filename_from_sop(sop)
    dirname = os.path.dirname(new_filename)
    if not os.path.exists(dirname):
        if DRY:
            print("would create dir:", dirname)
        else:
            os.makedirs(dirname)
    try:
        if DRY:
            print(f"would copy {current_filename} -> {new_filename}")
        else:
            shutil.copy(current_filename, new_filename)
    except FileExistsError: pass

    return new_filename


def sops_from_activity(db_conn, activity_id: int):
    cur = db_conn.cursor()
    cur.execute("""
        select max(activity_timepoint_id)
        from activity_timepoint
        where activity_id = %s
    """, [activity_id])

    activity_timepoint_id = cur.fetchone()

    cur.execute("""
        select storage_path(file_id), sop_instance_uid
        from activity_timepoint_file
        natural join file_sop_common
        where activity_timepoint_id = %s
    """, [activity_timepoint_id])

    for path, sop in cur:
        yield sop, path


def main(activity_id: int,
         base_dir: str = "/nas/public/test-storage",
         dry_run: bool = False):
    """Queue existing files for thumbnail generation, from an activity.

    Args:
        activity_id: the Activity ID to send

        base_dir: the base location where files are expected to be. Defaults to: /nas/public/test-storage
        dry_run: If set, talk verbosely about what would be done if it weren't set.
    """
    global TOKEN
    global BASE_DIR
    global DRY

    copy_into_place = True
    BASE_DIR = base_dir
    DRY = dry_run

    redis_db = redis.StrictRedis(host="tcia-posda-rh-2.ad.uams.edu", db=0)
    print("Connected to redis...")

    psql_db_conn = psycopg2.connect(dbname=PSQL_DB_NAME)
    psql_db_conn.autocommit = True
    psql_db_cur = psql_db_conn.cursor()
    print("Connected to postgres...")
    
    print(f"Calculating filenames...")
    files = []
    for i, (sop, source_path) in enumerate(sops_from_activity(psql_db_conn, activity_id)):
        new_filename = make_filename_from_sop(sop)
        files.append(new_filename)
    print(f"Done. {i+1} files processed.")


    print("Beginning thumbnail submit...")
    for filename in track(files, description="Submitting..."):
        print(filename)
        redis_db.lpush("thumbnails_required", filename)

    print("Done.")


if __name__ == "__main__":
    Fire(main)
