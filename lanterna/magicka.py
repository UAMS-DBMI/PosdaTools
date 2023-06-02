#!/usr/bin/python3 -u
USAGE="""\
Render MIP projections for review in Kaleidoscope.

By default, run in a loop and process all waiting IECs.

See optional arguments for more ways to run.

"""
import psycopg2
import tempfile
import subprocess
import os
import hashlib
from enum import Enum
from typing import List
import time
import sys
import shutil
import logging

import requests
import argparse


URL = os.environ.get("POSDA_INTERNAL_API_URL") + '/v1/import/'
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
            logging.error(r.content)
            raise

def log_dir_contents(directory):
    logging.error("Running identify on all files in the temp dir now:")
    for f in os.scandir(directory):
        subprocess.check_call([
            'identify',
            os.path.join(directory, f.name)
        ])

def convert_tempfiles_to_projection(directory: str, 
                                    output_filename: str, 
                                    projection_type: ProjectionType) -> None:
    logging.debug(f"converting {directory} to {output_filename}")
    commands = [
        'convert',
        f'{directory}/*.jpg',
        projection_type.value,
        output_filename
    ]
    logging.debug(f">> {commands}")
    try:
        subprocess.check_call(commands)
    except subprocess.CalledProcessError as e:
        logging.error("converting to projection failed!")
        log_dir_contents(directory)
        raise e


def convert_filelist_to_tempfiles(files: list, output_directory: str) -> None:
    for i, filename in enumerate(files):
        logging.debug(f"{i}: {filename}")

        # here we output into a temp dir for this file 
        # because if IM fails, it may produce extra bogus files that
        # we need to ignore..
        try:
            with tempfile.TemporaryDirectory() as tempdir:
                outfile = os.path.join(tempdir, f"{i}.jpg")
                final_location = os.path.join(output_directory, f"{i}.jpg")
                subprocess.check_call([
                    'convert',
                    "-define", "dcm:rescale=true",
                    "-define", "dcm:unsigned=true",
                    filename,
                    outfile
                ])
                # copy the single produced output file into the other directory
                # if an exception occurrs in here, no file will end up in 
                # the true output directory
                logging.debug(f"copying from {outfile} to {final_location}")
                shutil.copy(outfile, final_location)

        except:
            logging.info("convert failed due to previous error, trying dcm4che...")
            subprocess.check_call([
                '/opt/dcm4che-5.22.1/bin/dcm2jpg',
                filename,
                f"{output_directory}/{i}.jpg"
            ])

def make_montage(min_file: str, max_file: str, avg_file: str, output_filename: str) -> None:
    commands = [
        'montage',
        max_file,
        avg_file,
        min_file,
        '-geometry',
        '512x512+4+4',
        output_filename
    ]
    logging.debug(f">> {commands}")
    subprocess.call(commands)

def render_projection_from_filelist(files: list) -> str:
    """Render a full projection montage from the given list of files

    Returns the filename to the output image, which must be manually
    deleted after use.
    """

    temp_dir = tempfile.TemporaryDirectory()
    convert_filelist_to_tempfiles(files, temp_dir.name)

    # by using png for the output format, we avoid including the
    # rendered projections in the subsequent renders
    max_file = os.path.join(temp_dir.name, "max.png")
    min_file = os.path.join(temp_dir.name, "min.png")
    avg_file = os.path.join(temp_dir.name, "avg.png")

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

    logging.info(f"Rendering projection for IEC: {iec}.")
    # look up the input files
    cursor.execute("""
        select root_path || '/' || rel_path as path, number_of_frames
        from image_equivalence_class_input_image
        natural join file_location
        natural join file_storage_root
        natural join file_image
        natural join image
        where image_equivalence_class_id = %s
    """, [iec])
    
    # get their paths
    # assemble into a filelist
    with tempfile.NamedTemporaryFile(delete=False) as outfile:
        files = []
        for path, number_of_frames in cursor:
            if number_of_frames is not None:
                if number_of_frames > 1:
                    raise TypeError("This IEC contains files with "
                                    "multiple frames. Projections for "
                                    "these files are currently disabled!")
            files.append(path.encode())

        logging.info(f"Found {len(files)} images in this IEC.")

        projection_filename = render_projection_from_filelist(files)

        # import final file into posda and get file_id
        file_id = add_file(projection_filename)
        logging.debug(f"file_id: {file_id}")

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
    logging.info(f"Found {len(iecs)} IECs in visual review {visual_review_instance_id}.")
    if len(iecs) > 0:
        logging.info("Rendering projections...")

    for iec in iecs:
        try:
            render_projection(cur, iec)
        except Exception as e:
            log_error(cur, iec, e)

    conn.close()

def connect():
    conn = psycopg2.connect("dbname=posda_files")
    conn.autocommit = True
    # cur = conn.cursor()

    return conn


def log_error(cur, iec: int, e: Exception):
    logging.error(f"Magicka ERROR: IEC {iec} failed, err is: {e}")
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

def parse_args():
    parser = argparse.ArgumentParser(description=USAGE)
    parser.add_argument('--vr', help='a visual_review_instance_id to run for')
    parser.add_argument('--iec', help='an IEC to run for')
    parser.add_argument(
        '--debug',
        action='store_true',
        help='be extremely verbose'
    )

    return parser.parse_args()

def main(args) -> None:
    if args.vr is not None:
        logging.info(f"Processing a single VR: {args.vr}")
        process_single_vr(args.vr)
    elif args.iec is not None:
        logging.info(f"Processing a single IEC: {args.iec}")
        cur = connect().cursor()
        render_projection(cur, args.iec)
    else:
        logging.info("Processing all unprocessed IECs...")
        process_all_unprocessed()

def configure_logging(args):
    """Setup sane default logging settings"""
    if args.debug:
        format = "%(levelname)s:%(asctime)s:%(lineno)s:%(funcName)s:%(message)s"

        logging.basicConfig(level=logging.DEBUG,
                            format=format,
                            datefmt='%Y-%m-%d/%H:%M:%S')

    else:
        logging.basicConfig(level=logging.INFO,
                            format="%(message)s")

if __name__ == '__main__':
    args = parse_args()
    configure_logging(args)
    main(args)
