#!/usr/bin/python3.6 -u

import json
import os
import tempfile
import subprocess
import hashlib

import pydicom
import requests

from fire import Fire

URL = 'http://localhost/papi/v1/import/'

def md5sum(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

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
        print(r.content)
        raise


def get_xfer_syntax(filename):
    try:
        ds = pydicom.dcmread(filename)
        return ds.file_meta.TransferSyntaxUID
    except:
        return None

def fix_xfer_syntax(filename):
    """Convert the xfer syntax of the file, if needed

    Test the xfer syntax of this file; if pixels are not raw,
    we need to convert it to raw. The converted file
    is stored in a temporary location.

    
    Returns: (filename, original_filename)
    If conversion was necessary, filename will contain the new filename,
    and original_filename will contain the original filename, prefixed
    with "decompressed;". Example: "decompressed;/mnt/temp/files/some_file.dcm"


    If no conversion was done, both filename and original_filename will
    be equivalent.
    """

    current_syntax = get_xfer_syntax(filename)
    if (current_syntax == '1.2.840.10008.1.2.1' or 
        current_syntax is None or
        current_syntax == '1.2.840.10008.1.2'):
        return (filename, filename)
    else:
        print(current_syntax, end=' ')

    new_filename = tempfile.mktemp(prefix='iffpy')

    subprocess.run(["gdcmconv",
                    "-w",
                    "-i", filename,
                    "-o", new_filename])

    if os.path.exists(new_filename):
        # print(f"Successfully converted file: {new_filename}")
        print("V", end='')
        return (new_filename, f"decompressed;{filename}")
    else:
        print(f"Looks like this one failed: {new_filename}")
        return (None, None)

def import_one_file(import_event_id, line_obj):
    """import one file using the file_in_place endpoint"""

    filename = line_obj['filename']

    code, result = add_file(filename, import_event_id)
    if code != 200:
        print(code, result)
        return

    if result['created']:
        print("C", end='')

    print(f"|{result['file_id']}")

def main(filename, import_comment="CLI API Import", base_url="http://localhost"):
    global URL

    URL = f"{base_url}/papi/v1/import/"

    import_event_id = create_import_event(import_comment)

    # Each line of a plist should be a json-encoded dictionary
    with open(filename) as infile:
        for line in infile:
            obj = json.loads(line)
            import_one_file(import_event_id, obj)

    close_import_event(import_event_id)

    print(import_event_id)


if __name__ == '__main__':
    Fire(main)
    # main("acrin_6667.plist")
