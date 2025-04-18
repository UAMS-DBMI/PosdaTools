#!/usr/bin/env python3

import os
import json
import subprocess
import fire


def gen_files(path):
    for path, dnames, fnames in os.walk(path):
        for file in fnames:
            yield os.path.join(path, file)

def scan(path):
    # i = 0
    for file in gen_files(path):
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
