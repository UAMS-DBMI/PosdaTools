#!/usr/bin/python3 -u

import redis
import requests
import subprocess
import os
import tempfile
import hashlib
import platform
import logging

from posda.config import Config
import posda.logging.autoconfig

BASE_URL = None  # must be set in main()

def main_loop(redis_db, priority):

    while True:
        sr = redis_db.brpop("work_queue_{}".format(priority), 5)
        if sr is None:
            continue

        _, work_id = sr
        logging.info(f'new work item {work_id}')
        req = requests.get(f'{BASE_URL}/worker/status/{work_id}')
        if req.status_code != 200:
            logging.info(f'Work item status returned: {req.status_code}')
            continue
        work_item = req.json()
        logging.info(work_item)
        req = requests.get(f'{BASE_URL}/worker/subprocess/{work_item["subprocess_invocation_id"]}')
        if req.status_code != 200:
            logging.info(f'Subprocess info returned: {req.status_code}')
            continue
        subp = req.json()
        command_line = subp['command_line'].replace("<?bkgrnd_id?>", str(subp['subprocess_invocation_id']))
        logging.info(command_line)
        stdout_fp = tempfile.TemporaryFile()
        stderr_fp = tempfile.TemporaryFile()
        req = requests.get(f'{BASE_URL}/files/{work_item["input_file_id"]}/path')
        if req.status_code != 200:
            logging.info(f'Filepath returned: {req.status_code}')
            continue
        stdin_path = req.json()['file_path']
        stdin_fp = open(stdin_path)
        # TODO: this needs to be expanded to post some data - mostly the hostname
        # of the worker, but possibly other status info!!
        requests.post(f'{BASE_URL}/worker/status/{work_id}/running', 
                      data={"node_hostname": platform.node()})
        return_code = subprocess.Popen(command_line,
                                       shell=True,
                                       stdin=stdin_fp,
                                       stdout=stdout_fp,
                                       stderr=stderr_fp).wait()
        logging.info(f'Subprocess returned: {return_code}')
        stdin_fp.close()
        stdout_file_id = upload_file(stdout_fp)
        stderr_file_id = upload_file(stderr_fp)
        logging.info(f'stdout:{stdout_file_id} stderr:{stderr_file_id}')
        stdout_fp.close()
        stderr_fp.close()
        payload = {'stderr_file_id':stderr_file_id, 'stdout_file_id':stdout_file_id}
        if return_code != 0:
            requests.post(f'{BASE_URL}/worker/status/{work_id}/errored', json=payload)
        else:
            requests.post(f'{BASE_URL}/worker/status/{work_id}/finished', json=payload)

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
        logging.info(f'File uploading failed: {resp.status_code}')
        raise Exception("File upload failed")
    return resp.json()['file_id']


def main():
    global BASE_URL

    logging.info("worker node started")

    BASE_URL = Config.get('internal-api-url') + "/v1"
    redis_host = Config.get('redis-host', default='redis')
    worker_priority = Config.get('worker-priority', default=0)

    logging.info("using redis host: %s", redis_host)

    redis_db = redis.StrictRedis(host=redis_host, db=0, decode_responses=True)
    logging.info("connected to redis")

    main_loop(redis_db, worker_priority)


if __name__ == "__main__":
    main()
