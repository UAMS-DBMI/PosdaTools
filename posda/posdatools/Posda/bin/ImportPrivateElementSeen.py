#!/usr/bin/env python3
"""
Import Private Element Seen entries from an export from another system

This script imports the Private Element Seen data into the
posda_phi_simple database (element_seen table). If the element
already exists, only the disposition is updated. If the element
does not exist, all fields are added.

Expects lines on STDIN of the format: <element_signature>|<tag_name>|<vr>|<disposition>
"""
from posda.database import Database
from posda.background.process import BackgroundProcess
import csv
import argparse
import sys
import enum


class Queries(enum.Enum):
    get_element = """\
        select * 
        from element_seen
        where element_sig_pattern = %s 
          and vr = %s 
    """
    get_random_selection_of_data = """\
        with ids as (
                select distinct
                        value_seen_id
                from
                        element_value_occurance
                where
                        element_seen_id = %s
        ), values_ as (
                select value
                from value_seen
                where value_seen_id in (select * from ids)
        )

        select *
        from values_
        order by random()
        limit 25
    """
    insert_new_element = """
        insert into element_seen 
        (element_sig_pattern, vr, is_private, tag_name, private_disposition)
        values (%s, %s, true, %s, %s)
    """


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("background_id", help="the background_subprocess_id")
    parser.add_argument("activity_id", help="the primary activity to run against")
    parser.add_argument("notify", help="user to notify when complete")

    return parser.parse_args()


def parse_input(input_lines):
    """Collect the input and ensure it's in the right format"""
    tags = []
    for line in input_lines:
        parts = line.split("|")
        tags.append(parts)

        if len(parts) != 4:
            raise ValueError(
                "Input lines must be in the format: <element_signature>|<tag_name>|<vr>|<disposition>"
            )

    return tags


def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)

    input_lines = []
    for line in sys.stdin:
        input_lines.append(line.strip())

    background.daemonize()

    input_values = parse_input(input_lines)

    updates = []
    non_updated_count = 0
    needs_update_count = 0
    added_count = 0

    needs_update_report = background.create_report("Tags that need disposition update")
    needs_update_writer = csv.writer(needs_update_report)
    needs_update_writer.writerow(
        ["id", "Element Signature", "VR", "sample of values", "old disp", "disp"]
    )

    with Database("posda_phi_simple") as conn:
        cur = conn.cursor()
        for signature, tag_name, vr, disposition in input_values:
            cur.execute(Queries.get_element.value, (signature, vr))

            match = cur.fetchone()

            if match:
                if not match.private_disposition == disposition:
                    # get some sample values
                    cur.execute(
                        Queries.get_random_selection_of_data.value,
                        (match.element_seen_id,),
                    )

                    values = "\n".join([r.value for r in cur.fetchall()])

                    needs_update_count += 1
                    needs_update_writer.writerow(
                        [
                            match.element_seen_id,
                            signature,
                            vr,
                            values,
                            match.private_disposition,
                            disposition,
                        ]
                    )
                else:
                    non_updated_count += 1
            else:
                print(
                    f"> Element {signature} with VR {vr} does not exist, adding new entry"
                )
                added_count += 1

                # add the new entry for real
                cur.execute(
                    Queries.insert_new_element.value,
                    (signature, vr, tag_name, disposition),
                )

    # print a report of the counts
    print(f"Non-updated count: {non_updated_count}")
    print(f"Needs update count: {needs_update_count}")
    print(f"Added count: {added_count}")

    background.finish(
        f"Done! {non_updated_count} non-updated {needs_update_count} need update {added_count} added"
    )


if __name__ == "__main__":
    args = parse_args()
    main(args)
