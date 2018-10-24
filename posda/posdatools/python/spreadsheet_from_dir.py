#!/usr/bin/env python3.6

import pydicom
from posda.util import md5sum
from posda.background import BackgroundProcess
from posda.main import args

import os
import sys
import csv
from multiprocessing import Pool, Queue

help = """
Build a spreadsheet report from a directory.

This script does not read from stdin.
"""

parser = args.Parser(
    arguments=[args.Presets.background_id, 
               args.CustomArgument("scan_dir", 
                                   "The directory to build the report from"),
               args.Presets.notify],

    purpose="Build a report from a directory",
    help=help)
pargs = parser.parse()

print(f"Building report for dir: {pargs.scan_dir}")
print(f"This script does not read lines from stdin, so no lines read")

background = BackgroundProcess(pargs.background_id, pargs.notify)

background.daemonize()

background.log_input_count(0)

print(f"Scanning dir: {pargs.scan_dir}")

report = background.create_report()

def build_report(filename):
    ds = pydicom.read_file(filename)
    s = md5sum(filename)
    stat = os.stat(filename)
    return [filename,
            ds.private_data_element(0x13, "CTP", 0x10).value,
            ds.private_data_element(0x13, "CTP", 0x12).value,
            ds.PatientID,
            ds.SeriesInstanceUID,
            ds.SOPInstanceUID,
            s,
            stat.st_size]

pool = Pool() # automatically uses # of cpu cores

writer = csv.writer(report)
headers = "filename,collection,site,patient,series,sop,md5sum,size".split(',')
writer.writerow(headers)

result_count = 0

def write_result(result):
    global result_count
    result_count += 1
    writer.writerow(result)

for path, dirs, files in os.walk(pargs.scan_dir):
    for file in files:
        filename = os.path.join(path, file)
        pool.apply_async(build_report, (filename,), callback=write_result)

pool.close()
pool.join()

print("Files processed:", result_count)

background.finish()
