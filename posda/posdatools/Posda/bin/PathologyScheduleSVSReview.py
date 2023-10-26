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

def process(filepath, original_file):


    with Database("posda_files").cursor() as cur:
        #import the file
        file_id = insert_file(filepath)
        os.unlink(filepath)  # clean up temp file
        #update table that tracks the relationship between preview files and the original file
        Query("InsertPathPreviewFiles").execute(
                path_file_id = original_file,
                preview_file_id = file_id)

#def saveTiffMetaData(mytif, file_id):
   #print('\n***********\n')
   #for p, page in enumerate(mytif.pages):
       #if page.tags['ImageDescription']:
            #print('ImageDescription:\n')
            #print(page.tags['ImageDescription'].value)
            #print('\n')

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
        Query("InsertPathVRFiles").execute(
                pathology_visual_review_instance_id = vr_id,
                path_file_id = file_id)
        if (myfilename[-3:].lower() == "svs"):
            mytif = TiffFile(svsfilepath)
            #saveTiffMetaData(mytif, file_id)
            for i, page in enumerate(mytif.pages):
                if (i == 1 or page.tags['NewSubfileType'] != 0 ) and (page.size < 5000000): # Potentially switch to using mytif.series info instead 1 and NewSubfileType?
                    data = page.asarray()
                    str = "/tmp/{}_page{}.jpg".format(file_id,i)
                    strg1 = "/tmp/{}_thumb_gamma1.jpg".format(file_id)
                    im = Image.fromarray(data)
                    myimg_g = gammaShift(im)
                    myimg_g.save(strg1)
                    im.save(str) #create thumbnail
                    #print(f"Creating an svs preview")
                    process(str, file_id) #import thumbnail
                    process(strg1, file_id)
        elif(myfilename[-3:].lower() == "tif" or myfilename[-4:].lower() == "tiff") :
            mytif = TiffFile(svsfilepath)
            #saveTiffMetaData(mytif, file_id)
            for i, page in enumerate(mytif.pages):
                data = page.asarray()
                str = "/tmp/{}_page{}.jpg".format(file_id,i)
                strg1 = "/tmp/{}_thumb_gamma1.jpg".format(file_id)
                im = Image.fromarray(data)
                im.save(str) #create copy
                mytif2 = Image.open(str)
                size = (700,700)
                myimg_g = gammaShift(mytif2)
                myimg_g.thumbnail(size) #change copy into a thumbnail
                myimg_g.save(strg1)
                mytif2.thumbnail(size) #change copy into a thumbnail
                mytif2.save(str)
                #print(f"Creating a tif preview")
                process(str, file_id) #import thumbnail
                process(strg1, file_id)
        elif(myfilename[-3:].lower() == "jpg" or myfilename[-4:].lower() == "jpeg" or myfilename[-3:].lower() == "bmp" or myfilename[-3:].lower() == "png" or myfilename[-3:].lower() == "PNG" ):
                myimg = Image.open(svsfilepath)
                str = "/tmp/{}_thumb_gamma0.jpg".format(file_id)
                strg1 = "/tmp/{}_thumb_gamma1.jpg".format(file_id)
                size = (700,700)
                myimg_g = gammaShift(myimg)
                myimg_g.thumbnail(size) #change copy into a thumbnail
                myimg_g.save(strg1)
                myimg.thumbnail(size) #change copy into a thumbnail
                myimg.save(str) #save thumbnail
                #print(f"Creating a jpg/bmp preview")
                process(str, file_id) #import thumbnail
                process(strg1, file_id)

    background.finish(f"Thumbnail files created and imported")

def gammaShift(myimg):
    gammaValue = 1.0 / 2.2
    lookup = [int(255 * (i / 255.0) ** gammaValue) for i in range(256)]
    lookup = lookup * 3
    new_image = myimg.point(lookup)
    return new_image


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Takes an Activity and creates the thumbnails for review for the SVS files")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
