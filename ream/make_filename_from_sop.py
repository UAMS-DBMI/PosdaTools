#!/usr/bin/env python3
import hashlib
import sys

BASE_DIR=''

def make_filename_from_sop(sop):
    md5 = hashlib.md5()
    md5.update(sop.encode())
    digest = md5.hexdigest()

    path = "{}/{}/{}/{}.dcm".format(
        digest[:2],
        digest[2:4],
        digest[4:6],
        digest
    )

    return BASE_DIR + '/' + path

def main():
    sop = sys.argv[1]
    print(make_filename_from_sop(sop))

if __name__ == '__main__':
    main()
