#!/usr/bin/env python3

import os
import sys
import csv
import argparse

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.nifti.parser import NiftiParser

about="""\
This script creates a Nifti Visual review.
"""

def create_nifti_visual_review(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    #print(f'Activity ID: {args.activity_id}')
    #print(f'Notify: {args.notify}')

    vr_id = Query("CreateNiftiVisualReviewInstance").get_single_value(
            activity_creation_id = args.activity_id,
            scheduler = args.notify)

    #print(f'VR ID: {vr_id}')

    results = []
    for row in Query("NiftiFilePathsFromActivity").run(activity_id=args.activity_id):
        results.append((row.file_id, os.path.join(row.root_path, row.rel_path), row.file_name))

    for (file_id, file_path, file_name) in results:
        
        #print(f'File: {file_id} : {file_name}')

        Query("InsertNiftiVRFiles").execute(
                nifti_visual_review_instance_id = vr_id,
                nifti_file_id = file_id,
                nifti_file_name = file_name)

    background.finish(f"Nifti files recorded for Visual Review")

def main(args):
    create_nifti_visual_review(args)

def parse_args():
    parser = argparse.ArgumentParser(description=about)
    parser.add_argument('background_id', nargs='?', default='', help='the background_subprocess_id (blank for CL Mode)')
    parser.add_argument('activity_id', help='the activity nifti files are in')
    parser.add_argument('notify', help='user to notify when complete')
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())