#!/usr/bin/env python3

import argparse
import redis
import os
from posda.config import Config


keyname = "dicom-receive-to-process"
REDIS_HOST = Config.get("redis_host")

def parse_args():
    parser = argparse.ArgumentParser(description='some program')
    parser.add_argument('dirname', help='the directory to scan and queue')

    return parser.parse_args()

def main(dirname):
    redis_db = redis.StrictRedis(host=REDIS_HOST, db=0)

    for i, f in enumerate(os.listdir(dirname)):
        fullpath = os.path.join(dirname, f)
        redis_db.lpush(keyname, fullpath)
        if i % 1000 == 0:
            print(i)


if __name__ == "__main__":
    args = parse_args()
    main(args.dirname)
