#!/usr/bin/env python3

import os
import sys
import json
import subprocess
import fire


def gen_files():
    for filename in sys.stdin:
        yield filename.strip()

def scan():
    # i = 0
    for file in gen_files():
        try:
            stat = os.stat(file)
        except FileNotFoundError:
            # Some strange files can't be read; just skip them I guess
            continue
        # ftype = (subprocess.check_output(['file', '-b', '-i', file])).decode()

        print(json.dumps({
            'filename': file,
            # 'type': ftype,
            'size': stat.st_size,
            'ctime': stat.st_ctime
        }))

        # if i > 10:
        #     break
        # i += 1

if __name__ == '__main__':
    fire.Fire(scan)
