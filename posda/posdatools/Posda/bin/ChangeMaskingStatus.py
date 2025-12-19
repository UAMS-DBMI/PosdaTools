#!/usr/bin/env python3
import argparse
import csv
import sys
from typing import List, Tuple

from posda.database import Database
from posda.background.process import BackgroundProcess
from psycopg2.extras import execute_values

usage = """\
ChangeMaskingStatus.py <?bkgrnd_id?> <activity_id> <masking_status> <notify>
  <activity_id> - activity
  <masking_status> - masking status to set for each IEC
  <notify> - user to notify

Expects the following list on <STDIN>
  <image_equivalence_class_id>
"""


def parse_updates(default_status: str) -> List[Tuple[int, str]]:
    """Read STDIN for IEC ids, assuming input lines are valid."""
    updates: List[Tuple[int, str]] = []

    for raw_line in sys.stdin:
        line = raw_line.strip().rstrip("\x1a")
        if not line:
            continue

        try:
            iec_id = int(line)
        except ValueError:
            print(f"Skipping non-numeric IEC input: {line!r}")
            continue
        updates.append((iec_id, default_status))

    return updates


def update_status(conn: Database, updates: List[Tuple[int, str]]) -> int:
    """Bulk update masking_status for the provided IEC ids."""
    if not updates:
        return 0

    query = """
        update masking as m
        set masking_status = data.masking_status::masking_status_type
        from (values %s) as data(image_equivalence_class_id, masking_status)
        where m.image_equivalence_class_id = data.image_equivalence_class_id
    """

    with conn.cursor() as cur:
        execute_values(cur, query, updates)

    return len(updates)


def write_report(background: BackgroundProcess, updates: List[Tuple[int, str]]) -> None:
    report = background.create_report("Masking_Status_Updates")
    writer = csv.writer(report, lineterminator='\n')
    writer.writerow(["image_equivalence_class_id", "masking_status"])
    for iec_id, status in updates:
        writer.writerow([iec_id, status])


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("background_id", help="the background_subprocess_id")
    parser.add_argument("activity_id", help="the primary activity to run against")
    parser.add_argument("masking_status", help="default masking status if omitted per line")
    parser.add_argument("notify", help="user to notify when complete")
    args = parser.parse_args()
    if args.background_id == "-":
        args.background_id = ""
    return args


def generate_arg_report(args):

    print("ChangeMaskingStatus.py running with the following arguments:")
    print(f"Activity ID: {args.activity_id}")
    print(f"Default Masking Status: {args.masking_status}")

    print("------------------------------------------")


def main2(args, background):
    generate_arg_report(args)

    updates = parse_updates(args.masking_status)
    print(f"Prepared {len(updates)} update(s)")

    conn = Database("posda_files")
    updated = update_status(conn, updates)
    print(f"Updated {updated} image equivalence class(es)")

    write_report(background, updates)

    background.finish("Complete")


def main(args):
    """
    Main entry point, just wraps the other main and catches
    exceptions, so that the script always finishes. It still
    exits with a nonzero exit code so the script will be flagged
    as failed.
    """
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    try:
        main2(args, background)
    except Exception as e:
        print("FATAL ERROR:", e)
        background.finish("Failed")
        raise e

    return 0


if __name__ == "__main__":
    sys.exit(main(parse_args()))
