#!/usr/bin/env python3

import argparse
import csv
import sys
import os

from tifffile import TiffFile
from PIL import Image
from posda.database import Database
from posda.queries import Query
#from posda.background.process import BackgroundProcess
from posda.main.file import insert_file


def process(filepath, original_file,vr_id):


    with Database("posda_files").cursor() as cur:
        #import the file
        file_id = insert_file(filepath)
        #update table that tracks the relationship between preview files and the original file
        Query("InsertPathVRFiles").execute(
                pathology_visual_review_instance_id = vr_id,
                svsfile_id = original_file,
                preview_file_id = file_id)

def main(args):
    #background = BackgroundProcess(args.background_id, args.notify, args.activity_id)

    vr_id = Query("CreatePathologyVisualReviewInstance").get_single_value(
            activity_creation_id = args.activity_id,
            scheduler = args.notify);


    results = []
    for row in Query("FilePathsFromActivity").run(
            activity_id=args.activity_id):
        results.append((row.file_id, os.path.join(row.root_path, row.rel_path)))
    for (file_id, svsfilepath) in results:
        mytif = TiffFile(svsfilepath)
        for i, page in enumerate(mytif.pages):
            if (i == 1 or page.tags['NewSubfileType'] != 0 ) and (page.size < 5000000):
                data = page.asarray()
                str = "/home/posda/cache/created/{}_page{}.jpg".format(file_id,i)
                im = Image.fromarray(data)
                im.save(str) #create thumbnail
                #print("Images Saved! Import Processing!")
                process(str, file_id,vr_id) #import thumbnail


#    background.finish(f"Thumbnail files created and imported")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Takes an Activity and creates the thumbnails for review for the SVS files")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
