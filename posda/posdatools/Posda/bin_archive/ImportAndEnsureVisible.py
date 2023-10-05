#!/usr/bin/env python3

import argparse
import csv
import sys

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess

from posda.main.file import insert_file


def process(background, lines):
    report = background.create_report('Import Report')
    writer = csv.writer(report)
    writer.writerow(["filename", "file_id"])

    with Database("posda_files").cursor() as cur:
        for i, line in enumerate(lines):
            if len(line) < 1:
                continue

            file_id = insert_file(line)
            cur.execute("update ctp_file "
                        "set visibility = null "
                        "where file_id = %s", [file_id])

            writer.writerow([line, file_id])

            if i % 1000 == 0:
                background.set_activity_status(f"{i} of {len(lines)}")

def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)

    lines = [line.strip() for line in sys.stdin]
    print(f"Read {len(lines)} lines from STDIN. Going to background now.")

    background.print_to_email(f"Processing {len(lines)} lines.")

    background.daemonize()

    try:
        process(background, lines)
    except Exception as e:
        print(e)
        background.set_activity_status(f"error: {e}")

    background.finish(f"{len(lines)} files imported and unhidden")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Import files from STDIN and ensure they are visible")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    args = parser.parse_args()

    main(args)
