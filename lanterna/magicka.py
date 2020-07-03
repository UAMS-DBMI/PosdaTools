#!/usr/bin/python3 -u

import psycopg2
import tempfile
import subprocess
import os
import hashlib
from enum import Enum
from typing import List
import time
from threading import Thread
from queue import Queue, Empty

import requests
import fire

URL = 'http://web/papi/v1/import/'
DEBUG = True 
Q = Queue()
P = None

class Dcm4cheError(RuntimeError): pass

class ProjectionType(Enum):
    MIN = "-minimum"
    AVG = "-average"
    MAX = "-maximum"

def md5sum(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def add_file(filename: str) -> int:
    digest = md5sum(filename)
    with open(filename, "rb") as infile:
        r = requests.put(URL + "file", params={
            'digest': digest,
        }, data=infile)

        try:
            resp = r.json()
            return resp['file_id']
        except:
            print(r.content)
            raise

def call_convert(filelist: str, output_filename: str, projection_type: ProjectionType) -> None:
    subprocess.call([
        'convert',
        "-define", "dcm:rescale=true",
        "-define", "dcm:unsigned=true",
        f'@{filelist}',
        projection_type.value,
        output_filename
    ])

def make_montage(min_file: str, max_file: str, avg_file: str, output_filename: str) -> None:
    subprocess.call([
        'montage',
        max_file,
        avg_file,
        min_file,
        '-geometry',
        '512x512+4+4',
        output_filename
    ])

def render_projection(cursor, iec: int) -> None:
    print(f"Rendering projection for IEC: {iec}.")
    # look up the input files
    cursor.execute("""
        select root_path || '/' || rel_path as path
        from image_equivalence_class_input_image
        natural join file_location
        natural join file_storage_root
        where image_equivalence_class_id = %s
    """, [iec])
    
    # get their paths
    # assemble into a filelist
    with tempfile.TemporaryDirectory() as outdir:
    # with tempfile.NamedTemporaryFile(delete=False) as outfile:
        # TODO call dcm2jpg on all the files here, first, putting
        # them into temp files? then write into the outfile

        outfile = open(os.path.join(outdir, "filelist"), "w")
        for i, (path,) in enumerate(cursor):
            jpeg_file = os.path.join(outdir, f"{i}.jpg")
            try:
                dcm2jpg(path, jpeg_file)
            except Dcm4cheError as e:
                print(f"Magicka ERROR: IEC {iec} one frame failed, err is: {e}")

            outfile.write(jpeg_file)
            outfile.write('\n')
        outfile.close()
        print(f"Found {i} images in this IEC.")

        # call IM to produce min, max, avg projections
        call_convert(outfile.name, "min.jpg", ProjectionType.MIN)
        call_convert(outfile.name, "max.jpg", ProjectionType.MAX)
        call_convert(outfile.name, "avg.jpg", ProjectionType.AVG)

        # call IM to produce montage
        make_montage("min.jpg", "max.jpg", "avg.jpg", "full.jpg")

        # import final file into posda and get file_id
        file_id = add_file("full.jpg")
        if DEBUG:
            print(f"file_id: {file_id}")

        # insert row into output_image table
        cursor.execute("""
            insert into image_equivalence_class_out_image
            values (%s, 'combined', %s)
        """, [iec, file_id])

        # update iec table to ReadyToReview
        cursor.execute("""
            update image_equivalence_class
            set processing_status = 'ReadyToReview'
            where image_equivalence_class_id = %s
        """, [iec])

        # clean up temp files
        os.unlink(outfile.name)
        os.unlink("min.jpg")
        os.unlink("max.jpg")
        os.unlink("avg.jpg")
        os.unlink("full.jpg")

def get_iecs_in_visual_review(cursor, visual_review_id: int) -> List[int]:
    cursor.execute("""
        select image_equivalence_class_id
        from image_equivalence_class
        where visual_review_instance_id = %s
    """, [visual_review_id])

    return [iec for iec, in cursor]

def process_single_vr(visual_review_instance_id: int) -> None:
    conn = connect()
    cur = conn.cursor()


    iecs = get_iecs_in_visual_review(cur, visual_review_instance_id)
    print(f"Found {len(iecs)} IECs in visual review {visual_review_instance_id}.")
    if len(iecs) > 0:
        print("Rendering projections...")

    for iec in iecs:
        render_projection(cur, iec)

    conn.close()

def connect():
    conn = psycopg2.connect("dbname=posda_files")
    conn.autocommit = True
    # cur = conn.cursor()

    return conn


def log_error(cur, iec: int, e: Exception):
    print(f"Magicka ERROR: IEC {iec} failed, err is: {e}")
    query = """
        update image_equivalence_class i
        set processing_status = 'error'
        where i.image_equivalence_class_id = %s
    """
    cur.execute(query, [iec])


def process_all_unprocessed():
    conn = connect()
    cur = conn.cursor()

    query = """
        update image_equivalence_class i
        set processing_status = 'in-progress'
        where i.image_equivalence_class_id in (
          select image_equivalence_class_id
          from image_equivalence_class
          where processing_status = 'ReadyToProcess'
          limit 1
          for update skip locked
        )
        returning i.*
    """

    while True:
        cur.execute(query)
        row = cur.fetchone()
        if row is None:
            time.sleep(5)  # sleep 5 seconds
            continue

        iec, *rest = row
        try:
            render_projection(cur, iec)
        except Exception as e:
            log_error(cur, iec, e)


def setup_dcm4che():
    global Q
    global P
    def enqueue_output(out, queue):
        for line in iter(out.readline, b''):
            queue.put(line.decode().strip())
        out.close()

    P = subprocess.Popen("dcm2jpg2", stdout=subprocess.PIPE, stdin=subprocess.PIPE, bufsize=0)
    t = Thread(target=enqueue_output, args=(P.stdout, Q))
    t.daemon = True # thread dies if the program dies
    t.start()

    # read 2 lines from p, startup messages
    l1 = Q.get(timeout=1)
    l2 = Q.get(timeout=1)

def dcm2jpg(src, dst):
    """Convert a dcm to jpg, using dcm4che's dcm2jpg"""

    P.stdin.write(f"{src}|{dst}\n".encode())

    output = None
    errors = []
    try:
        # read the first (expected) line, wait a while for it
        output = Q.get(timeout=5)
        if not "->" in output:
            # read any other lines (from a stack trace, for example)
            errors.append(output)
            while True:
                errors.append(Q.get(timeout=.1))
    except Empty: # Empty is raised when the queue is empty
        pass


    if len(errors) > 0:
        raise Dcm4cheError(' '.join(errors))

def main(visual_review_instance_id: int = None) -> None:
    """If visual_review_instance_id is specified, 
    process that Visual Review and exit.

    If visual_review_instance_id is not specified,
    begin processing all IECs in ReadyToProcess status,
    and never exit."""

    setup_dcm4che()

    if visual_review_instance_id is not None:
        print("Processing single VR...")
        process_single_vr(visual_review_instance_id)
    else:
        print("Processing all unprocessed IECs...")
        process_all_unprocessed()


if __name__ == '__main__':
    fire.Fire(main)
