#!/usr/bin/python3.6 -u

import json
import os
import tempfile
import subprocess
import hashlib

import pydicom
import requests

from fire import Fire

URL = 'http://tcia-posda-rh-2.ad.uams.edu/papi/v1/import/'

def md5sum(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def create_import_event():
    r = requests.put(URL + "event", params={
        'source': "A test from python" # TODO: fix this
    })

    resp = r.json()
    return resp['import_event_id']

def close_import_event(import_event_id):
    r = requests.post(URL + f"event/{import_event_id}/close")
    resp = r.json()


def add_file(filename, import_event_id):
    digest = md5sum(filename)
    with open(filename, "rb") as infile:
        r = requests.put(URL + "file", params={
            'import_event_id': import_event_id,
            'digest': digest,
        }, data=infile)

        try:
            resp = r.json()
            return resp
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

    file, original_file = fix_xfer_syntax(line_obj['filename'])
    if file is None:
        print("Skipping due to previous errors. If this is happening a lot you might want to abort")
        return
    size = line_obj['size']


    result = add_file(file, import_event_id)
    if result['created']:
        print("C", end='')

    print(f"|{result['file_id']}")

    if original_file.startswith('decompressed;'):
        os.unlink(file)


def main(filename):

    import_event_id = create_import_event()

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
