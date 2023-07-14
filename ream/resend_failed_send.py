#!/usr/bin/python3 -u

import json
import time
import os
from typing import NamedTuple
import hashlib

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

def failed_files_from_copy(cursor, subprocess_invocation_id):
    cursor.execute("""
        select storage_path(file_id), sop_instance_uid
        from public_copy_status 
        natural join file_sop_common
        where subprocess_invocation_id = %s 
        and success = false
    """, [subprocess_invocation_id])

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

def copy_sops_into_place(sops):
    # sops should be: [(sop, current_filename), ..]

    ret = []
    for sop, current_filename in sops:
        new_filename = make_filename_from_sop(sop)
        dirname = os.path.dirname(new_filename)
        if not os.path.exists(dirname):
            os.makedirs(dirname)
        try:
            os.symlink(current_filename, new_filename)
        except FileExistsError: pass
        ret.append(new_filename)

    return ret

def main(subprocess_invocation_id: int,
         collection_name: str,
         site_name: str,
         site_id: int,
         base_dir: str = "/nas/public/storage-from-posda"):
    """Resend failed files for a subprocess_invocation_id

    For each success=false file in public_copy_status, this program will:
        1) calculate the expected filename
        2) verify the file exists in that location
        3) submit the file via the NBIA API

    Args:
        subprocess_invocation_id:
        collection_name: the collection name to submit to the API
        site_name: the site name to submit to the API
        site_id: the 8 digit site id contianing collection_code and site_code

        base_dir: the base location where files are expected to be (or will be placed). Defaults to: /nas/public/storage-from-posda

    """
    global TOKEN
    global BASE_DIR

    BASE_DIR = base_dir

    print(f"Collection: {collection_name}")
    print(f"Site: {site_name}")
    print(f"Site ID: {site_id}")


    psql_db_conn = psycopg2.connect(dbname=PSQL_DB_NAME)
    psql_db_conn.autocommit = True
    psql_db_cur = psql_db_conn.cursor()
    print("# connected to postgres")


    # with open(sop_list_file, "r") as infile:
    #     sops = [
    #         row.strip()
    #         for row in infile
    #     ]
    # print("Sops read from file:", len(sops))

    # get all failed files from public_copy_status
    # select file_id from public_copy_status where subprocess_invocation_id = 21854 and success = false;


    # generate the expected filename
    filenames = failed_files_from_copy(psql_db_cur, subprocess_invocation_id)

    print(filenames)
    return

    # verify they exist
    existing_files = list(filter(os.path.exists, filenames))
    print(f"Found {len(existing_files)} files.")

    TOKEN = login_or_die()
    print(f"logged in to api, token={TOKEN}")

    print("Beginning send...")
    for filename in existing_files:
        f = File(0, 0, collection_name, site_name, site_id, 0, filename)
        try:
            submit_file(f)
        except SubmitFailedError as e:
            print(e)


if __name__ == "__main__":
    Fire(main)
