#!/usr/bin/python3.6 -u

import os

import posda.background.fork
import posda.main
from posda.main import args, printe
from posda.util import unpack_n
from posda.subprocess import lines
from posda.queries import Query

help = """
Runs a scan for PHI.

 file_query_name can be one of:
    "IntakeFilesInSeries" - get list of series in intake database
    "PublicFilesInSeries" - get list of series in public database
    "FilesInSeries" - get list of series in posda database

Expects a list of series on STDIN
"""

parser = args.Parser(
    arguments=[args.Presets.background_id, 
               args.Presets.description, 
               args.CustomArgument("file_query_name", 
                                   "Name of query to use for getting list of "
                                   "files in given series"), 
               args.Presets.notify],

    purpose="Background Process to scan for PHI",
    help=help)
args = parser.parse()

# TODO: this (and some other stuff) could be moved into
# an util lib, posda.background.shortcuts or something?

subprocess_id = Query("CreateBackgroundSubprocess").get_single_value(
    subprocess_invocation_id=args.background_id,
    command_executed='???',
    foreground_pid=os.getpid(),
    user_to_notify=args.notify
)

if subprocess_id is None or subprocess_id == 0:
    raise RuntimeError("Failed to get subprocess ID")

print(f"Subprocess_id is: {subprocess_id}")

input_lines = posda.main.get_stdin_input()

print(f"Found list of {len(input_lines)} series to scan")
print("Forking background process")


###############################################################################
parent_pid, my_pid = posda.background.fork.daemonize()

Query("AddBackgroundTimeAndRowsToBackgroundProcess").execute(
    input_rows=len(input_lines), 
    background_pid=my_pid, 
    background_subprocess_id=subprocess_id)

get_series_count = Query(args.file_query_name)

scan_id = Query("CreateSimplePhiScanRow").get_single_value(
    description=args.description, 
    num_series=len(input_lines), 
    file_query=args.file_query_name
)

# create queries we are going to use multiple times
# TODO: ^ that

for series in input_lines:
    printe(f"Processing {series}")

    count = 0

    for row in get_series_count.run(series):
        count += 1

    printe(f"Found {count} files in this series.")

    series_scan_id = Query("CreateSimpleSeriesScanInstance").get_single_value(
        scan_instance_id=scan_id,
        series_instance_uid=series
    )

    cmd = "PhiSimpleSeriesScan.pl"
    command = [cmd, series, args.file_query_name]

    for line in lines(command):
        tagp, vr, value = unpack_n(line.split('|'), 3)

        if value is None:
            continue

        tag_id = Query("GetSimpleElementSeen").get_single_value(tagp, vr)
        if tag_id is None:
            tag_id = Query("CreateSimpleElementSeen").get_single_value(tagp, vr)

        value_id = Query("GetSimpleValueSeen").get_single_value(value)
        if value_id is None:
            value_id = Query("CreateSimpleValueSeen").get_single_value(value)

        Query("CreateSimpleElementValueOccurance").execute(
            tag_id, value_id, series_scan_id, scan_id)


    Query("FinalizeSimpleSeriesScan").execute(count, series_scan_id)
    Query("IncrementSimpleSeriesScanned").execute(scan_id)

Query("FinalizeSimpleScanInstance").execute(scan_id)
printe(f"Scan has been finalized: {len(input_lines)} / {scan_id}")
