#!/usr/bin/env python3
# coding: utf-8
"""
DCIODVFY Macro

This program parses the Posda dciodvfy output and adds an extra column
with fixes, based on the rules defined in RULES_FILE
"""

import argparse
import sys
import csv

RULES_FILE = "rules.csv"


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="input file to process")
    parser.add_argument(
        "--out", "-o", default="out.csv", help="output file to write to"
    )

    return parser.parse_args()


def apply_dciodvfy_macro(rules, reader, writer):
    for series, errors in reader:
        errors = errors.strip()
        # split the cell on lines, will reassemble later
        messages = []
        for line in errors.split("\n"):
            line = line.strip()
            if len(line) > 0:
                # see if there is a rule that matches
                for rule in rules:
                    # rules are all substrings that just need
                    # to match the line, so here we can use in
                    if rule in line:
                        # do not include empty rules
                        # TODO: we might need to delete these entries
                        # from the errors list?
                        if rules[rule] != "":
                            # replacing the rule text with the fix text,
                            # rather than just using the fix txt, ensures
                            # that any extra values in the message are
                            # preserved
                            messages.append(line.replace(rule, rules[rule]))

        # reassemble cell
        writer.writerow([series, errors, "\n".join(messages)])


def main(input_filename, output_filename):
    """
    Simpler/faster? version that doesn't use pandas
    """
    # these files can have extremely large cells; set the single-cell
    # limit to something insanely big
    csv.field_size_limit(sys.maxsize // 10)

    rules = {}
    with open(RULES_FILE) as f:
        reader = csv.reader(f)
        next(reader)
        for match, replace in reader:
            rules[match] = replace

    with open(input_filename) as infile:
        with open(output_filename, "w") as outfile:
            writer = csv.writer(outfile)
            reader = csv.reader(infile)

            # output header row
            writer.writerow(["Series", "Errors", "Fix"])

            # skip the header row
            next(reader)

            apply_dciodvfy_macro(rules, reader, writer)


if __name__ == "__main__":
    args = parse_args()
    main(args.input, args.out)
