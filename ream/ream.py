#!/usr/bin/python3 -u

import redis
import json
import time
import os
from typing import NamedTuple

import requests
import psycopg2


URL=os.environ['REAM_URL']
USER=os.environ['REAM_USER']
PASS=os.environ['REAM_PASS']
CLIENTID=os.environ['REAM_CLIENTID']
CLIENTSECRET=os.environ['REAM_CLIENTSECRET']
RETRY_COUNT=int(os.environ['REAM_RETRY_COUNT'])
PSQL_DB_NAME=os.environ['REAM_PSQL_DB_NAME']

TOKEN=None

class LoginFailedError(RuntimeError): pass
class LoginExpiredError(RuntimeError): pass
class SubmitFailedError(RuntimeError): pass

class File(NamedTuple):
    subprocess_invocation_id: int
    file_id: int
    collection: str
    site: str
    site_id: int
    batch: int
    filename: str
    third_party_analysis_url: str


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
        except requests.exceptions.ConnectionError as e:
            errors.append(e)
            print("WAIT: Server rejected connection, waiting 1 second for retry...")
            time.sleep(1)  # wait a bit for the server to get over it's funk
        except LoginExpiredError:
            TOKEN = login_to_api()

    raise SubmitFailedError(("Failed to submit the file; error details follow", f, errors))


def _submit_file(f):
    tpa_url = f.third_party_analysis_url

    if tpa_url is None:
        tpa_url = ''

    if len(tpa_url) > 0:
        tpa = "yes"
    else:
        tpa = "NO"

    payload = {'project': f.collection,
               'siteName': f.site,
               'siteID': f.site_id,
               'batch': f.batch,
               'uri': f.filename,
               'thirdPartyAnalysis': tpa,
               'descriptionURI': tpa_url,
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

def main():
    global TOKEN

    print("ream, starting up...")

    redis_db = redis.StrictRedis(host="redis", db=0)
    print("connected to redis")

    psql_db_conn = psycopg2.connect(dbname=PSQL_DB_NAME)
    psql_db_conn.autocommit = True
    psql_db_cur = psql_db_conn.cursor()
    print("connected to postgres")


    TOKEN = login_or_die()
    print(f"logged in to api, token={TOKEN}")

    main_loop(redis_db, psql_db_cur)



if __name__ == "__main__":
    main()
