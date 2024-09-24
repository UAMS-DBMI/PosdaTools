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
from random import random
#from posda.main.file import insert_file


def saveTiffMetaData(mytif, activity_id, file_id, phi_scan_id):
    for p, page in enumerate(mytif.pages):
        for t, tag in enumerate(page.tags):
            if tag.name not in ('BitsPerSample','Compression','ImageDepth', 'ImageLength', 'ImageWidth', 'TileLength', 'TileWidth', 'RowsPerStrip', 'SamplesPerPixel', 'YCbCrSubSampling', 'JPEGTables', 'TileOffsets', 'TileByteCounts', 'InterColorProfile' ):
                if sys.getsizeof(tag.value) < 2500:
                    #save the image description data
                    if tag.name == 'ImageDescription':
                        Query("InsertPathologyImageDesc").execute(file_id = file_id, layer_id = p, image_desc = str(tag.value))
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

#Someday convert this a generic Posda Python function
def createCSVReports(phi_scan_id, background):
     result_data =  Query("RunTiffPHIReport").run(tiff_phi_scan_instance_id = phi_scan_id)
     result_list = list(result_data)
     result_container = []
     for i in range(0,len(result_list),500):
        result_container.append(result_list[i:i+500])
     for j in range(len(result_container)):
        cname = "tiff_phi_{0}_{1}.csv".format(phi_scan_id,j)
        r = background.create_report(cname)
        writer = csv.writer(r)
        writer.writerow(['Tag Name','Value','Page ID','File ID'])
        for k in result_container[j]:
            my_data = k._asdict()
            writer.writerow([my_data['tag_name'],my_data['value'],my_data['page_id'],my_data['file_id']])



def main(args):
    usage = '''
    Usage:
    PathologyPhiScan.pl <?bkgrnd_id?> <activity_id> <notify>

    Description: Saves tag and value data from tiff files in the activity to the db,
    skipping tags known to have low phi incidence
    BitsPerSample,Compression,ImageDepth, ImageLength, ImageWidth, TileLength, TileWidth, RowsPerStrip,SamplesPerPixel, YCbCrSubSampling, JPEGTables, TileOffsets, TileByteCounts, InterColorProfile '''

    desc =  "Tiff PHI Scan for activity {0}".format(args.activity_id)
    print ("***")
    print (args.activity_id)
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    results = []
    background.print_to_email("Activity {0} ".format(args.activity_id))
    phi_scan_id = Query("CreateTiffPHIScan").get_single_value(description = desc)
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

    createCSVReports(phi_scan_id, background)
    background.finish("Tag data has been saved. Tiff PHI Scan ID:{0}".format(phi_scan_id))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Creates a Tiff PHI Review instance and saves the tiff tag and value data for report retrival")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
