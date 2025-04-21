#!/usr/bin/env python3
import json
import os
import tempfile
import subprocess
import hashlib
import sys

import pydicom
import requests

from posda.database import Database
from posda.config import Config

# URL = 'http://localhost/papi/v1/import/'
URL = Config.get("internal_api_url") + "/v1/import/"
# print(URL)

def printe(*args):
    """Print, but to STDERR"""
    print(*args, file=sys.stderr)

def create_import_event(import_comment):
    r = requests.put(URL + "event", params={
        'source': import_comment
    })

    resp = r.json()
    return resp['import_event_id']

def close_import_event(import_event_id):
    r = requests.post(URL + f"event/{import_event_id}/close")
    resp = r.json()


def add_file(filename, import_event_id):
    """add one file using file_in_place endpoint"""

    r = requests.post(URL + "file_in_place", params={
        'import_event_id': import_event_id,
        'localpath': filename,
    })

    try:
        resp = r.json()
        return r.status_code, resp
    except:
        return r.status_code, r.content


def get_xfer_syntax(filename):
    try:
        ds = pydicom.dcmread(filename)
        return ds.file_meta.TransferSyntaxUID
    except:
        return None

def import_one_file(import_event_id, filename):
    """import one file using the file_in_place endpoint"""

    code, result = add_file(filename, import_event_id)
    if code != 200:
        printe(code, result, filename)
        return False

    if result['created']:
        ccode = "C"
    else:
        ccode = " "

    print(f"{ccode}|{result['file_id']}")

    return True

def main():

    import_comment="CLI API Import"
    import_event_id = create_import_event(import_comment)
    project_name = 'CPTAC-AML'

    with Database("public") as conn:
        cur = conn.cursor()

        cur.execute("""\
            select gi.dicom_file_uri
            from general_series gs
            join general_image gi 
                on gi.general_series_pk_id = gs.general_series_pk_id
            where gs.project = %s
        """, [project_name])

        for uri, in cur:
            # Each line of a plist should be a json-encoded dictionary
            import_one_file(import_event_id, uri)

    close_import_event(import_event_id)

    print(import_event_id)


if __name__ == '__main__':
    main()
