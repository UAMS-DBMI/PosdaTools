#!/usr/bin/env python3

import argparse
import csv
import sys
import os


from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess


def main(args,mappingData):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    results = []
    count = 0
    for row in Query("FilePathsFromActivity").run(activity_id=args.activity_id):
        results.append((row.file_id, os.path.join(row.root_path, row.rel_path)))
    for (file_id, svsfilepath) in results:
        mypath = Query("SimpleFilenameFetch").get_single_value(file_id = file_id)
        myfilename = os.path.basename(mypath)
        if myfilename in mappingData:
          count = count+1
          Query("InsertPathologyPatientMapping").execute(file_id = file_id,patient_id = mappingData[myfilename],original_file_name = myfilename,collection_name = args.collection_name, site_name = args.site_name)
    print("Patholgy patient mapping created.\n{0} files mapped out of {1} files in mapping.\nActivity total files {2}.\n".format(count, len(results)+1, len(row)+1))
    background.finish("Complete")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyCreatePatientMapping")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    parser.add_argument("collection_name")
    parser.add_argument("site_name")

    args = parser.parse_args()

    #get the STDIN data
    mappingData = {}
    for line in sys.stdin:
        patient_id, file_name = (line.rstrip()).split('&')
        mappingData[file_name] = patient_id
    main(args,mappingData)
