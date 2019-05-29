import requests
import os
import hashlib


def ensure_blank_system():
    r = requests.get("http://localhost/papi/v1/collections")
    assert r.json() == [], "should be empty"



def generate_files():
    for root, subdirs, files in os.walk('data'):
        for f in files:
            yield os.path.join(root, f)


def load_test_data():
    for f in generate_files():
        data = open(f, 'rb').read()
        m = hashlib.md5()
        m.update(data)
        res = requests.put(url='http://localhost/papi/v1/import/file',
                            data=data,
                            params={'digest': m.hexdigest()},
                            headers={'Content-Type': 'application/octet-stream'})

        if res.status_code == 200:
            obj = res.json()
            print(obj['created'], obj['file_id'])
        else:
            print(res.status_code)
            print(res.content)


# ensure_blank_system()
load_test_data()
