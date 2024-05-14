#!/usr/bin/env python3

import argparse
import csv
import sys
import os
from openslide import OpenSlide
from tifffile import TiffFile
from PIL import Image, ImageFile
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.main.file import insert_file
from random import random
Image.MAX_IMAGE_PIXELS = None

def process(filepath, original_file, gammaI):
    with Database("posda_files").cursor() as cur:
        #import the file
        file_id = insert_file(filepath)
        os.unlink(filepath)  # clean up temp file
        #update table that tracks the relationship between preview files and the original file
        #print("Processing")
        Query("InsertPathPreviewFiles").execute(
                path_file_id = original_file,
                preview_file_id = file_id,
                gammaindex = gammaI)
        #print("Processed")

def is_increasing(sequence): #used to verify layers are pyramidal
    return all(earlier < later for earlier, later in zip(sequence, sequence[1:]))

def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    vr_id = Query("CreatePathologyVisualReviewInstance").get_single_value(
            activity_creation_id = args.activity_id,
            scheduler = args.notify)


    results = []
    scan_started = False
    desc = "Tiff PHI Scan for activity {0}".format(args.activity_id)
    for row in Query("FilePathsFromActivity").run(
            activity_id=args.activity_id):
        results.append((row.file_id, os.path.join(row.root_path, row.rel_path)))
    for (file_id, svsfilepath) in results:
        myfilename = Query("SimpleFilenameFetch").get_single_value(file_id = file_id)
        Query("InsertPathVRFiles").execute(
                pathology_visual_review_instance_id = vr_id,
                path_file_id = file_id)
        if (myfilename[-3:].lower() == "svs"): #Aperio File
            mytif = TiffFile(svsfilepath)
            if not scan_started:
                phi_scan_id = Query("CreateTiffPHIScan").get_single_value(description = desc)
                background.print_to_email("Tiff PHI Scan ID:{0}".format(phi_scan_id))
                scan_started = True
            if scan_started:
                saveImageMetaData(mytif,args.activity_id,file_id,phi_scan_id)
            for i, page in enumerate(mytif.pages):
                if (i == 1 or page.tags['NewSubfileType'] != 0 ) and (page.size < 5000000): # Potentially switch to using mytif.series info instead 1 and NewSubfileType?
                    data = page.asarray()
                    im = Image.fromarray(data)
                    gammaSet(im, file_id,i, False)
        elif(myfilename[-3:].lower() == "tif" or myfilename[-4:].lower() == "tiff" or myfilename[-4:].lower() == "ndpi" or myfilename[-4:].lower() == "mrxs" ): #Tiff, Hanamatsu, or Mirax file
             myImage = OpenSlide((svsfilepath))
             print("Trying to use OpenSlide, {}".format(myImage))
             if is_increasing(myImage.level_downsamples):
                 closest_level = myImage.get_best_level_for_downsample(max(myImage.level_dimensions[0]) / 700)
                 downsampled_dimensions = myImage.level_dimensions[closest_level]
                 im = myImage.read_region((0, 0), closest_level, downsampled_dimensions)
                 im_rgb = im.convert('RGB')
                 gammaSet(im_rgb,file_id,0,False)
             else:
                 print('Warning: Layers may not be the same image! Cannot make thumbnail!')

        elif(myfilename[-3:].lower() == "jpg" or myfilename[-4:].lower() == "jpeg" or myfilename[-3:].lower() == "bmp" or myfilename[-3:].lower() == "png" or myfilename[-3:].lower() == "PNG" ): #non-layered file
                myimg = Image.open(svsfilepath)
                gammaSet(myimg,file_id,0, True)

    background.finish(f"Thumbnail files created and imported")

def gammaShift(myimg,v):
    gammaValue = 1.0 / v
    lookup = [int(255 * (i / 255.0) ** gammaValue) for i in range(256)]
    if myimg.mode != 'L' and myimg.mode != 'LA':  #greyscale should not be multiplied
        lookup = lookup * 3
    new_image = myimg.point(lookup)
    return new_image

def gammaSet(myImage,file_id,page, thumbs):
    size = (700,700)
    gammaV = [0.4,0.2,0, 1.2,2.2]
    for i in range(len(gammaV)):
        image = myImage
        if (thumbs):
            image.thumbnail(size)
        if i != 2: #do not gamma the base image (value 0).
            image = gammaShift(image, gammaV[i])
        str = "/tmp/{}_thumb_page{}_gamma{}.jpg".format(file_id,page,i)
        #print("Preview file {} created, which is gamma value {}".format(str, gammaV[i]))
        image.save(str)
        process(str, file_id, i)

def saveImageMetaData(mytif, activity_id, file_id, phi_scan_id):
    for p, page in enumerate(mytif.pages):
        for t, tag in enumerate(page.tags):
            if tag.name not in ('BitsPerSample','Compression','ImageDepth', 'ImageLength', 'ImageWidth', 'TileLength', 'TileWidth', 'RowsPerStrip', 'SamplesPerPixel', 'YCbCrSubSampling', 'JPEGTables', 'TileOffsets', 'TileByteCounts', 'InterColorProfile' ):
                if sys.getsizeof(tag.value) < 2500:
                    #save the image description data
                    if tag.name == 'ImageDescription':
                       Query("InsertPathologyImageDesc").execute(file_id = file_id, image_desc = str(tag.value))
                    #Determine if the tag is public or private
                    if tag.code < 32768:
                        priv = False
                    else:
                        priv = True
                    #save tags and values for reporting
                    tag_seen_id = Query("GetTiffTagSeen").get_single_value(tag_name = tag.name)
                    if not tag_seen_id:
                        tag_seen_id = Query("InsertTiffTagSeen").get_single_value(is_private=priv,tag_name = tag.name)
                    value_seen_id = Query("GetTiffValueSeen").get_single_value(value = str(tag.value))
                    if not value_seen_id:
                        value_seen_id = Query("InsertTiffValueSeen").get_single_value(value = str(tag.value))
                    Query("InsertTiffValueOccurrence").execute(tiff_tag_seen_id = tag_seen_id,tiff_value_seen_id = value_seen_id,tiff_phi_scan_instance_id = phi_scan_id, page_id = p,file_id = file_id)
                else:
                    #note oversized tag.
                    print('*** Tag: {0} has data to large to save. ***'.format(tag.name))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Takes an Activity and creates the thumbnails for review for the SVS files")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
