#!/usr/bin/env python3

import argparse
import csv
import sys
import os

from tifffile import TiffFile
#from PIL import Image, ImageFile
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
#from posda.main.file import insert_file
#Image.MAX_IMAGE_PIXELS = None


def saveTiffMetaData(mytif, activity_id, file_id, phi_scan_id):
    for p, page in enumerate(mytif.pages):
        for t, tag in enumerate(page.tags):
            tag_seen_id = Query("GetTiffTagSeen").get_single_value(tag_name = tag.name)
            #save the image description data
            if tag_seen_id == 'ImageDescription':
               Query("InsertPathologyImageDesc").run(file_id = file_id, image_desc = tag.value)
            #Determine if the tag is public or private
            if tag.code < 32768:
                priv = False
            else:
                priv = True
            #save tags and values for reporting
            if not tag_seen_id:
                tag_seen_id = Query("InsertTiffTagSeen").get_single_value(is_private=priv,tag_name = tag.name)
            value_seen_id = Query("GetTiffValueSeen").get_single_value(value = tag.value)
            if not value_seen_id:
                value_seen_id = Query("InsertTiffValueSeen").get_single_value(value = tag.value)
            Query("InsertTiffValueOccurance").run(tiff_tag_seen_id = tag_seen_id,tiff_value_seen_id = value_seen_id,tiff_phi_scan_instance_id = phi_scan_id,file_id = file_id)
    background.finish("Tag data has been saved. Tiff PHI Scan ID:{0}".format(phi_scan_id))

def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    results = []
    phi_scan_id = Query("CreateTiffPHIScan").get_single_value(description = "Tiff Phi scan for Activity {0}".format(args.activity_id))
    background.print_to_email("Tiff PHI Scan ID:{0}".format(phi_scan_id))
    for row in Query("FilePathsFromActivity").run(
            activity_id=args.activity_id):
        results.append((row.file_id, os.path.join(row.root_path, row.rel_path)))
        for (file_id, svsfilepath) in results:
            myfilename = Query("SimpleFilenameFetch").get_single_value(file_id = file_id)
            #print("Creating previews for file " + svsfilepath + " : " + myfilename )
            if (myfilename[-3:].lower() == "svs" or myfilename[-3:].lower() == "tif" or myfilename[-4:].lower() == "tiff"):
                mytif = TiffFile(svsfilepath)
                saveTiffMetaData(mytif, args.activity_id, file_id,phi_scan_id)


    background.finish("Tag data has been saved.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PHI_Review_Report_for_Pathology_Tiffs")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
