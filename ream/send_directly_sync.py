#!/usr/bin/python3 -u

import json
import time
import os
import shutil
from typing import NamedTuple
import hashlib
from pprint import pprint

import requests
import psycopg2
from fire import Fire


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
    
    full_url = URL + "/nbia-api/services/submitDICOM"
    # pprint(full_url)
    # pprint(headers)
    # pprint(payload)
    req = requests.post(full_url, headers=headers, data=payload)

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
            # copyfile copies the file but NOT the metadata
            # This is to prevent copying files that are user readable only
            shutil.copyfile(current_filename, new_filename)
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
        select file_id, storage_path(file_id), sop_instance_uid
        from activity_timepoint_file
        natural join file_sop_common
        where activity_timepoint_id = %s
    """, [activity_timepoint_id])

    for file_id, path, sop in cur:
        yield file_id, sop, path


def main(activity_id: int,
         collection_name: str,
         site_name: str,
         site_id: int,
         base_dir: str = "/nas/public/test-storage",
         dry_run: bool = False,
         limit_count: int = 0):
    """Send existing files via the NBIA Submissions API, from Posda

    This program submits files to NBIA via the NBIA Submissions API.

    The files must be in Posda, and the environment must be configured
    for the Posda instance you want to send from. This program must
    be able to access the files directly, wherever they are. The files
    are NOT modified (Private Dispositions are not applied, nor are any
    tags removed, such as Site Name).

    For each file in the current timepiont for the activity_id, this program will:
        1) calculate the expected filename
        2) copy the file into that location
        3) submit the file via the NBIA API

    NOTE: The Collection, Site and Site ID are NOT read from the source
          files, but are specified directly on the command line!

    Args:
        activity_id: the Activity ID to send
        collection_name: the collection name to submit to the API
        site_name: the site name to submit to the API
        site_id: the 8 digit site id containing site_code and collection_code

        base_dir: the base location where files are expected to be (or will be placed). Defaults to: /nas/public/test-storage
        dry_run: If set, talk verbosely about what would be done if it weren't set.
    """
    global TOKEN
    global BASE_DIR
    global DRY

    copy_into_place = True
    BASE_DIR = base_dir
    DRY = dry_run

    print(f"Collection: {collection_name}")
    print(f"Site: {site_name}")
    print(f"Site ID: {site_id}")


    psql_db_conn = psycopg2.connect(dbname=PSQL_DB_NAME)
    psql_db_conn.autocommit = True
    psql_db_cur = psql_db_conn.cursor()
    print("# connected to postgres")
    
    TOKEN = login_or_die()
    print(f"logged in to api, token={TOKEN}")

    #### NOTE: We copy all files first, then submit, because of timing
    #          issues with the NAS. We need to give the files time to show
    #          up on the server.

    print(f"Copying files into place...")
    files = []
    for i, (file_id, sop, source_path) in enumerate(sops_from_activity(psql_db_conn, activity_id)):
        files.append((file_id, copy_sop_into_place(sop, source_path)))
        if i % 100 == 0:
            print(i)

        if limit_count > 0 and i + 1 >= limit_count:
            break

    print(f"Done. {i+1} files copied.")

    print("Beginning submit...")
    for file_id, filename in files:
        f = File(-1, file_id, collection_name, site_name, site_id, 0, filename)
        if DRY:
            print("would now submit:", f)
        else:
            try:
                submit_file(f)
                print("Submitted:", f)
            except SubmitFailedError as e:
                print(e)


if __name__ == "__main__":
    Fire(main)
