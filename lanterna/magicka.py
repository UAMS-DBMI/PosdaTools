#!/usr/bin/python3 -u

import psycopg2
import tempfile
import subprocess
import os
import hashlib
from enum import Enum
from typing import List
import time

import requests
import fire

URL = 'http://web/papi/v1/import/'
# URL = 'http://tcia-posda-rh-1.ad.uams.edu/papi/v1/import/'
DEBUG = True

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

def convert_tempfiles_to_projection(directory: str, 
                                    output_filename: str, 
                                    projection_type: ProjectionType) -> None:
    subprocess.call([
        'convert',
        "-define", "dcm:rescale=true",
        "-define", "dcm:unsigned=true",
        f'{directory}/*.png',
        projection_type.value,
        output_filename
    ])

def convert_filelist_to_tempfiles(files: list, output_directory: str) -> None:
    for i, filename in enumerate(files):
        print(i)
        subprocess.call([
            'convert',
            "-define", "dcm:rescale=true",
            "-define", "dcm:unsigned=true",
            filename,
            f"{output_directory}/{i}.png"
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

def render_projection_from_filelist(files: list) -> str:
    """Render a full projection montage from the given list of files

    Returns the filename to the output image, which must be manually
    deleted after use.
    """

    temp_dir = tempfile.TemporaryDirectory()
    convert_filelist_to_tempfiles(files, temp_dir.name)

    # by using jpeg for the output format, we avoid including the
    # rendered projections in the subsequent renders
    max_file = os.path.join(temp_dir.name, "max.jpg")
    min_file = os.path.join(temp_dir.name, "min.jpg")
    avg_file = os.path.join(temp_dir.name, "avg.jpg")

    convert_tempfiles_to_projection(temp_dir.name, max_file, ProjectionType.MAX)
    convert_tempfiles_to_projection(temp_dir.name, min_file, ProjectionType.MIN)
    convert_tempfiles_to_projection(temp_dir.name, avg_file, ProjectionType.AVG)

    output_filename = tempfile.mktemp(suffix='.jpg')
    make_montage(min_file, max_file, avg_file, output_filename)

    temp_dir.cleanup()

    return output_filename


def render_projection(cursor, iec: int) -> None:
    """Render a projection of the given IEC

    This method follows these steps:
    * build a filelist of all input files for the IEC
    * use convert to generate png files for each input image in the filelist
    * create min, max, and avg projections from those files
    * generate a final montage
    """

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
    with tempfile.NamedTemporaryFile(delete=False) as outfile:
        # for i, (path,) in enumerate(cursor):
        #     outfile.write(path.encode())
        #     outfile.write(b'\n')
        # outfile.close()

        files = [path.encode() for path, in cursor]

        print(f"Found {len(files)} images in this IEC.")

        projection_filename = render_projection_from_filelist(files)

        # import final file into posda and get file_id
        file_id = add_file(projection_filename)
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
        os.unlink(projection_filename)

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


def main(visual_review_instance_id: int = None) -> None:
    """If visual_review_instance_id is specified, 
    process that Visual Review and exit.

    If visual_review_instance_id is not specified,
    begin processing all IECs in ReadyToProcess status,
    and never exit."""

    if visual_review_instance_id is not None:
        print("Processing single VR...")
        process_single_vr(visual_review_instance_id)
    else:
        print("Processing all unprocessed IECs...")
        process_all_unprocessed()

def test():
    # f = render_projection_from_filelist("test-filelist")
    # print(f)
    conn = connect()
    cur = conn.cursor()

    render_projection(cur, 399696)

    conn.close()


if __name__ == '__main__':
    # main(2)
    fire.Fire(main)
    # test()
