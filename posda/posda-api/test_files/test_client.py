#!/usr/bin/env python3

import requests
import os
import unittest

URL = 'http://localhost:8087/v1/import/'

@unittest.skip("Old tests, please ignore")
def create_import_event():
    r = requests.put(URL + "event", params={
        'source': "A test from python"
    })

    resp = r.json()
    return resp['import_event_id']

@unittest.skip("Old tests, please ignore")
def close_import_event(import_event_id):
    r = requests.post(URL + f"event/{import_event_id}/close")
    resp = r.json()


@unittest.skip("Old tests, please ignore")
def add_file(filename, import_event_id):
    with open(filename, "rb") as infile:
        r = requests.put(URL + "file", params={
            'import_event_id': import_event_id,
        }, data=infile)

        resp = r.json()
        return resp['file_id']

import_event_id = create_import_event()

ids = []

path = "files"
for i, f in enumerate(os.listdir(path)):
    filename = os.path.join(path, f)
    file_id = add_file(filename, import_event_id)
    ids.append(file_id)

    if i % 10 == 0:
        print(".")

close_import_event(import_event_id)

print(f"Added {len(ids)} files, with import_event_id {import_event_id}")
print(ids[:5])
print("...")
print(ids[-5:])
