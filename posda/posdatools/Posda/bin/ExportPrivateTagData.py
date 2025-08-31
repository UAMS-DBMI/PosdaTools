#!/usr/bin/env python3
"""
Export private tag data from the database.

Produces two reports: Private Tag KB, and Element Seen
"""
from posda.database import Database
from posda.background.process import BackgroundProcess
import csv
import argparse


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("background_id", help="the background_subprocess_id")
    parser.add_argument("activity_id", help="the primary activity to run against")
    parser.add_argument("notify", help="user to notify when complete")

    return parser.parse_args()


def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    private_tag_kb = background.create_report(f"Private tag kb")
    element_seen = background.create_report(f"Element seen")

    export(
        "private_tag_kb",
        """\
        select *
        from pt
    """,
        private_tag_kb,
    )

    export(
        "posda_phi_simple",
        """\
        select *
        from element_seen
        where is_private = true
    """,
        element_seen,
    )

    background.finish("Done!")


def export(database, query, outfile):
    with Database(database) as conn:
        cur = conn.cursor()
        cur.execute(query)

        writer = None

        for row in cur:
            rowdict = row._asdict()
            if writer is None:
                writer = csv.DictWriter(outfile, fieldnames=list(rowdict.keys()))
                writer.writeheader()

            writer.writerow(rowdict)


if __name__ == "__main__":
    args = parse_args()
    main(args)
