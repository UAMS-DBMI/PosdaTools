#!/usr/bin/python3 -u

import redis
import requests
import subprocess
import os
import tempfile
import hashlib

BASE_URL = 'http://web/papi/v1'

def main_loop(redis_db):

    while True:
        sr = redis_db.brpop("hp_work", 1)
        if sr is None:
            sr = redis_db.brpop("normal_work", 5)
        if sr is None:
            continue

        _, work_id = sr
        print(f'new work item {work_id}')
        req = requests.get(f'{BASE_URL}/worker/status/{work_id}')
        if req.status_code != 200:
            print(f'Work item status returned: {req.status_code}')
            continue
        work_item = req.json()
        print(work_item)
        req = requests.get(f'{BASE_URL}/worker/subprocess/{work_item["subprocess_invocation_id"]}')
        if req.status_code != 200:
            print(f'Subprocess info returned: {req.status_code}')
            continue
        subp = req.json()
        command_line = subp['command_line'].replace("<?bkgrnd_id?>", str(subp['subprocess_invocation_id']))
        print(command_line)
        stdout_fp = tempfile.TemporaryFile()
        stderr_fp = tempfile.TemporaryFile()
        req = requests.get(f'{BASE_URL}/files/{subp["spreadsheet_uploaded_id"]}/path')
        if req.status_code != 200:
            print(f'Filepath returned: {req.status_code}')
            continue
        stdin_path = req.json()['file_path']
        stdin_fp = open(stdin_path)
        requests.post(f'{BASE_URL}/worker/status/{work_id}/running')
        return_code = subprocess.Popen(command_line,
                                       shell=True,
                                       stdin=stdin_fp,
                                       stdout=stdout_fp,
                                       stderr=stderr_fp).wait()
        print(f'Subprocess returned: {return_code}')
        stdin_fp.close()
        stdout_file_id = upload_file(stdout_fp)
        stderr_file_id = upload_file(stderr_fp)
        print(f'stdout:{stdout_file_id}\nstderr:{stderr_file_id}')
        stdout_fp.close()
        stderr_fp.close()
        if return_code != 0:
            payload = {'stderr_file_id':stderr_file_id}
            requests.post(f'{BASE_URL}/worker/status/{work_id}/errored', data=payload)
        else:
            requests.post(f'{BASE_URL}/worker/status/{work_id}/finished')

def md5sum(fp):
    fp.seek(0)
    hash_md5 = hashlib.md5()
    for chunk in iter(lambda: fp.read(4096), b""):
        hash_md5.update(chunk)
    return hash_md5.hexdigest()

def upload_file(fp):
    digest = md5sum(fp)
    fp.seek(0)
    params = { 'digest': digest }
    resp = requests.put(f'{BASE_URL}/import/file', params=params, data=fp)
    if resp.status_code != 200:
        print(f'File uploading failed: {resp.status_code}')
        raise Exception("File upload failed")
    return resp.json()['file_id']


def main():
    print("worker node started")

    redis_db = redis.StrictRedis(host="redis", db=0, decode_responses=True)
    print("connected to redis")

    main_loop(redis_db)


if __name__ == "__main__":
    main()
