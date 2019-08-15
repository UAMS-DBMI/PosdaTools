#!/usr/bin/python3 -u

import sys
import time
import csv

from posda.queries import Query
from posda.background.process import BackgroundProcess

usage = """\
BackgroundHelloWorldWithInput.py <?bkgrnd_id?> <activity_id> <notify>
  <activity_id> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <series_instance_uid>

Constructs a spreadsheet with the following columns for all series:
  <collection>
  <site>
  <patient_id>
  <study_instance_uid>
  <study_date>
  <study_description>
  <series_instance_uid>
  <series_date>
  <series_desc>
  <modality>
  <dicom_file_type>
  <number_of_files>

Uses named query "SeriesInHierarchyBySeriesExtendedFurther"
"""

if len(sys.argv) != 4 or sys.argv[1] == '-h':
    print(usage)
    sys.exit(0)


_, invoc_id, activity_id, notify = sys.argv


# collect series from stdin
series = []
for line in sys.stdin:
    series.append(line.strip())
    
series_count = len(series)
print(f"Going to background to process {series_count} series")

background = BackgroundProcess(invoc_id, notify, activity_id)
background.daemonize()

q = Query("SeriesInHierarchyBySeriesExtendedFurther")
start = time.time()  # the epoch

# In python, after you call daemonize print will automatically
# print to the email
print("Initial line written to email")

hierarchy = None
report = background.create_report(f"DICOM Hierarchy for {series_count} series")

writer = csv.writer(report)
writer.writerow([
    "collection",
    "site",
    "patient_id",
    "study_instance_uid",
    "study_date",
    "study_description",
    "series_instance_uid",
    "series_date",
    "series_description",
    "modality",
    "dicom_file_type",
    "num_files",
])

for i, s in enumerate(series):
    background.set_activity_status(f"Querying {i} of {series_count}")
    for row in q.run(s):
        writer.writerow(tuple(row))


print("Final line written to email")
elapsed = time.time() - start
background.finish(f"Processed {series_count} in {elapsed} seconds")
