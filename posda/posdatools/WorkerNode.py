#!/usr/bin/env python3

import redis
import requests
import subprocess
import os

BASE_URL = 'http://web/papi/v1/worker'

def main_loop(redis_db):

    while True:
        print(".")
        sr = redis_db.brpop("normal_work", 5)
        if sr is None:
            continue

        _, work_id = sr
        print(f'new work item {work_id}')
        req = requests.get(f'{BASE_URL}/status/{work_id}')
        if req.status_code != 200:
            print(req.status_code)
            continue
        work_item = req.json()
        print(work_item)
        req = requests.get(f'{BASE_URL}/subprocess/{work_item["subprocess_invocation_id"]}')
        if req.status_code != 200:
            print(req.status_code)
            continue
        subp = req.json()
        command_line = subp['command_line'].replace("<?bkgrnd_id?>", str(subp['subprocess_invocation_id']))
        print(command_line)
        subprocess.run(command_line, shell=True, capture_output=True)


def main():
    print("worker node internal")

    redis_db = redis.StrictRedis(host="redis", db=0, decode_responses=True)
    print("connected to redis")

    main_loop(redis_db)


if __name__ == "__main__":
    main()
