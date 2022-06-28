#!/usr/bin/env python3

import argparse
import csv
import sys
import os

from tifffile import TiffFile
from PIL import Image, ImageFile
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.main.file import insert_file
Image.MAX_IMAGE_PIXELS = None

def process(filepath, original_file,vr_id):


    with Database("posda_files").cursor() as cur:
        #import the file
        file_id = insert_file(filepath)
        os.unlink(filepath)  # clean up temp file
        #update table that tracks the relationship between preview files and the original file
        Query("InsertPathVRFiles").execute(
                pathology_visual_review_instance_id = vr_id,
                path_file_id = original_file,
                preview_file_id = file_id)

def saveTiffMetaData(mytif, file_id):
   print('\n***********\n')
   for p, page in enumerate(mytif.pages):
       if page.tags['ImageDescription']:
            print('ImageDescription:\n')
            print(page.tags['ImageDescription'].value)
            print('\n')

def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    vr_id = Query("CreatePathologyVisualReviewInstance").get_single_value(
            activity_creation_id = args.activity_id,
            scheduler = args.notify)


    results = []
    for row in Query("FilePathsFromActivity").run(
            activity_id=args.activity_id):
        results.append((row.file_id, os.path.join(row.root_path, row.rel_path)))
    for (file_id, svsfilepath) in results:
        myfilename = Query("SimpleFilenameFetch").get_single_value(file_id = file_id)
        #print("Creating previews for file " + svsfilepath + " : " + myfilename )
        if (myfilename[-3:].lower() == "svs"):
            mytif = TiffFile(svsfilepath)
            saveTiffMetaData(mytif, file_id)
            for i, page in enumerate(mytif.pages):
                if (i == 1 or page.tags['NewSubfileType'] != 0 ) and (page.size < 5000000):
                    data = page.asarray()
                    str = "/tmp/{}_page{}.jpg".format(file_id,i)
                    im = Image.fromarray(data)
                    im.save(str) #create thumbnail
                    #print(f"Creating an svs preview")
                    process(str, file_id,vr_id) #import thumbnail
        elif(myfilename[-3:].lower() == "tif" or myfilename[-4:].lower() == "tiff") :
            mytif = TiffFile(svsfilepath)
            saveTiffMetaData(mytif, file_id)
            for i, page in enumerate(mytif.pages):
                data = page.asarray()
                str = "/tmp/{}_page{}.jpg".format(file_id,i)
                im = Image.fromarray(data)
                im.save(str) #create copy
                mytif2 = Image.open(str)
                size = (700,700)
                mytif2.thumbnail(size) #change copy into a thumbnail
                mytif2.save(str)
                #print(f"Creating a tif preview")
                process(str, file_id,vr_id) #import thumbnail
        elif(myfilename[-3:].lower() == "jpg" or myfilename[-4:].lower() == "jpeg" or myfilename[-3:].lower() == "bmp"):
                myimg = Image.open(svsfilepath)
                str = "/tmp/{}_thumb.jpg".format(file_id)
                size = (700,700)
                myimg.thumbnail(size) #change copy into a thumbnail
                myimg.save(str) #save thumbnail
                #print(f"Creating a jpg/bmp preview")
                process(str, file_id,vr_id) #import thumbnail

    background.finish(f"Thumbnail files created and imported")



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Takes an Activity and creates the thumbnails for review for the SVS files")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
