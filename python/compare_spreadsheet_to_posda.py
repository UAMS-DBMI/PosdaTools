#!/usr/bin/env python3.6

import csv
import sys

from posda.queries import Query
from posda.main import args
from posda.main import get_stdin_input
from posda.background import BackgroundProcess

from collections import namedtuple, defaultdict

help = """
A report is generated which compares each image, matching on SOP Instance UID.

Input is read from STDIN. Lines should be in the form:
    <filename>,<collection>,<site>,<patient>,<series>,<sop>,<md5sum>,<size>
(basically CSV)

An output report will be generated and emailed to NOTIFY, and will contain
details of the following discrepencies:
* SOPs missing from the file, or in Posda
* Duplicate SOP entires in file, or in Posda
* Data mismatch in Patient ID/Series Instance UID/File digest
"""

parser = args.Parser(
    arguments=[args.Presets.background_id, 
               args.CustomArgument("collection", 
                                   "The collection to compare against"),
               args.CustomArgument("site", 
                                   "The site to compare against"),
               args.Presets.notify],

    purpose="Compare a spreadsheet report to Posda",
    help=help)
pargs = parser.parse()

background = BackgroundProcess(pargs.background_id, pargs.notify)

reader = csv.reader(sys.stdin)
lines = {}

header = 'filename,collection,site,patient,series,sop,md5sum,size'.split(',')
InputLine = namedtuple("InputLine", header)
sop_seen_in_file = defaultdict(int)
for line in reader:
    background.log_input(line)
    input_line = InputLine(*line)
    lines[input_line.sop] = input_line
    sop_seen_in_file[input_line.sop] += 1

print(f"Read {len(lines)} input lines.")
background.daemonize()

sop_seen_in_query = defaultdict(int)
query = {}
for row in Query("PosdaImagesByCollectionSitePlus").run(
        collection=pargs.collection,
        site=pargs.site):
    query[row.sop_instance_uid] = row
    sop_seen_in_query[row.sop_instance_uid] += 1

Error = namedtuple("Error", ["sop", "type", "file_val", "posda_val"])
errors = []

def eq_or_err(sop, what, qval, lval):
    if lval != qval:
        errors.append(Error(sop, f"{what} mismatch", lval, qval))

for sop in lines:
    if sop not in query:
        errors.append(Error(sop, "missing in Posda", "", ""))
        continue

    q = query[sop]
    l = lines[sop]

    eq_or_err(sop, "patient", q.patient_id, l.patient)
    eq_or_err(sop, "series", q.series_instance_uid, l.series)
    eq_or_err(sop, "digest", q.digest, l.md5sum)

for sop in query:
    if sop not in lines:
        errors.append(Error(sop, "missing in file", "", ""))

for sop, k in sop_seen_in_file.items():
    if k > 1:
        errors.append(Error(sop, "duplicate sop in file", k, ""))

for sop, k in sop_seen_in_query.items():
    if k > 1:
        errors.append(Error(sop, "duplicate sop in query", "", k))

main_report = background.create_report()
writer = csv.writer(main_report)
writer.writerow(['sop', 'type', 'file_val', 'posda_val'])
writer.writerows(errors)

background.finish()
