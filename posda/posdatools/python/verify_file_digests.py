#!/usr/bin/python3 -u

import os
import sys
import psycopg2
import atexit
import signal
import hashlib
import fire

current_file_id = None

@atexit.register
def exit_handler():
    global current_file_id
    print("Exiting on:", current_file_id)


def sigusr1_handler(a, b):
    global current_file_id
    print("Current file_id:", current_file_id)

    # print("exiting for test")
    # sys.exit(1)

signal.signal(signal.SIGUSR1, sigusr1_handler)

def connect():
    return psycopg2.connect(database="posda_files")

def gen_files(cur, starting_file_id=0):
    while True:
        cur.execute("""
            select
                file_id, digest, size, storage_path(file_id) as path
            from file
            where file_id > %s
            order by file_id asc
            limit 100
        """, [starting_file_id])

        for file_id, digest, size, path in cur:
            yield (file_id, digest, size, path)

        starting_file_id = file_id  # keep going

def verify(digest: str, filename: str) -> bool:
    actual_digest = hashlib.md5(open(filename, 'rb').read()).hexdigest()
    return digest == actual_digest


def main(starting_file_id):
    global current_file_id

    print("Starting on", starting_file_id)

    conn = connect()
    cur = conn.cursor()

    for i, row in enumerate(gen_files(cur, starting_file_id)):

        file_id, digest, size, path = row
        current_file_id = file_id

        try:
            if not verify(digest, path):
                print(",".join([str(file_id), 'digest does not match', str(path)]))
        except FileNotFoundError:
            print(",".join([str(file_id), 'file not found', str(path)]))

    conn.close()

if __name__ == '__main__':
    fire.Fire(main)
