#!/usr/bin/env python3
import fire
import psycopg2
import psycopg2.extras
import pprint

conn = None

def get_file_digest(file_id: int) -> str:
    cur = conn.cursor()
    cur.execute("""
        select digest
        from file
        where file_id = %s
    """, [file_id])

    for digest, in cur:
        return digest

def digest_to_file_id(digest: str):
    cur = conn.cursor()
    cur.execute("""
        select file_id
        from file
        where digest = %s
    """, [digest])

    for file_id, in cur:
        return file_id


def get_details_of_to_file(to_file_digest: str):
    cur = conn.cursor()
    cur.execute("""
        select *
        from dicom_edit_compare
        where to_file_digest = %s
    """, [to_file_digest])

    return cur.fetchone()

def get_details_of_from_file(digest: str):
    pass

def print_file_report(file_id):
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
    cur.execute("""
        select *
        from file_series
        where file_id = %s
    """, [file_id])

    rec = cur.fetchone()
    pprint.pprint(dict(rec), depth=20)

def get_short_file_report(file_id: int, invoc_id: int):

    if invoc_id is None:
        return ()

    cur = conn.cursor()
    cur.execute("""

        select command_line,
               invoking_user,
               when_invoked
        from subprocess_invocation
        where subprocess_invocation_id = %s
    """, [invoc_id])

    cmd, user, when = cur.fetchone()

    return (when, user, cmd)

def get_parent_file_id(file_id: int):
    digest = get_file_digest(file_id)
    try:
        from_digest, to_digest, short_report, long_report, to_file_path, invoc_id = get_details_of_to_file(digest)
        from_file_id = digest_to_file_id(from_digest)
    except TypeError:
        from_file_id = None

    return from_file_id

def get_file_details(file_id: int):
    digest = get_file_digest(file_id)
    try:
        from_digest, to_digest, short_report, long_report, to_file_path, invoc_id = get_details_of_to_file(digest)
    except TypeError:
        invoc_id = None

    return get_short_file_report(file_id, invoc_id)


def main(file_id: int) -> None:
    global conn
    conn = psycopg2.connect(database="posda_files")

    print("First walking the edit history...")
    history = []

    while file_id is not None:
        history.append(file_id)
        file_id = get_parent_file_id(file_id)
    print("Found original file. History is as follows:")

    history = reversed(history)
    for i, file in enumerate(history):
        if i == 0:
            print("START: ", end='\t')
        else:
            print("       ", end='\t')
        print(file, end='\t')
        print('\t'.join([str(i) for i in get_file_details(file)]))
        # print_file_report(file)

    conn.close()

if __name__ == '__main__':
    fire.Fire(main)
    # main(49648605)
    # main(52025314)
