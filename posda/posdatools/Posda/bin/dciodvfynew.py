#!/usr/bin/env python3
"""\
DciodvfyNew - Intrepret and catagorize messages from dciodvfy with the
-new flag enabled.
"""
import sys
import csv
from collections import defaultdict
import re
import psycopg2
import subprocess
from enum import Enum
from dataclasses import dataclass
from pydicom.datadict import get_entry
import argparse


class Level(Enum):
    WARNING = 0,
    ERROR = 1,

class InvalidPathError(RuntimeError):
    pass

@dataclass(frozen=True)
class Message:
    level: Level
    path: str
    posda_path: str
    message: str

    def get_last_tag_entry(self):
        ## NOTE work on looking up the tags to get VR/VM
        parts = self.path.split('/')

        pattern = r"\(([a-f0-9]+),([a-f0-9]+)\)"
        last_part = parts[-1]

        if match := re.search(pattern, last_part):
            group = int(match.group(1), 16)
            ele = int(match.group(2), 16)

            return [group, ele, *get_entry((group, ele))]
        else:
            return None


    def should_drop(self) -> bool:
        """A list of messages that should not be reported"""

        if self.level == Level.WARNING:
            if "Retired Person Name form" in self.message:
                return True

            if "Missing attribute or value that would be needed to build DICOMDIR" in self.message:
                return True

        if self.level == Level.ERROR:
            pass

        # TODO this is for testing only and likely needs to be removed
        if len(self.path) == 0 or len(self.posda_path) == 0:
            return True

        return False

    def formatted_message(self):
        # TODO might add more formatting rules?
        return self.message.strip('- ')

    def formatted_full(self):
        # Tag: (0062,0020) UT 1 Tracking ID : Empty attribute (no value) Type 1C Conditional Element per module SegmentDescriptionMacro
        message = self.message.strip('- ')

        output = ""
        last_entry = self.get_last_tag_entry()
        if last_entry is not None:
            group, ele, vr, vm, desc, _, keyword = last_entry
            output = f"Tag: ({group:04x},{ele:04x}) {vr} {vm} {desc} : {message} | {self.level.name} | {self.path} | {self.posda_path}"

        return output

def convert_to_posda_format(path: str) -> str:
    """Convert DCIODVFY format DICOM path to Posda format

    Handles both public and private.
    """
    def convert_part_to_posda(part):
        if '"' in part: # if it contains a double quote, it's a private tag
            return convert_private_part_to_posda(part)
        else:
            return convert_public_part_to_posda(part)

    def convert_public_part_to_posda(part):
        def repl(match):
            group = match.group(1)
            element = match.group(2)

            return f"({group},{element})"

        pattern = r"\w+\(([a-f0-9]+),([a-f0-9]+)\)"
        new_text = re.sub(pattern, repl, part)

        # TODO need another pattern here to fix the [1] (reduce by 1)

        return new_text

    def convert_private_part_to_posda(part):
        def repl(match):
            group = match.group(1)
            element = match.group(2)
            owner = match.group(3)

            short_ele = element[-2:]

            return f"({group},\"{owner}\",{short_ele})"

        pattern = r"\(([a-f0-9]+),([a-f0-9]+),\"(.*)\"\)"

        new_text = re.sub(pattern, repl, part)

        return new_text

    path_parts = path.split("/")

    # There are some lines that are very oddly formatted, they will
    # likely need to be handled seperately
    if path_parts[0] != '':
        raise InvalidPathError(f"Path did not begin with a slash: {path}")

    path_parts = [convert_part_to_posda(x) for x in path_parts if x != '']

    combined_parts = "".join(path_parts)
    return f"<{combined_parts}>"


def process_line(line: str, level: Level) -> Message:
    # All warnings begin with a Path element enclosed in <>'s
    if "<" not in line:
        return Message(level, 'Missing Warning/Error token!', '', line)

    begin_idx = line.find("<")
    end_idx = line.find(">")

    path = line[begin_idx + 1:end_idx]
    message = line[end_idx + 1:]

    try:
        posda_path = convert_to_posda_format(path)
    except InvalidPathError as e:
        return Message(level, '', '', str(e))

    return Message(level, path, posda_path, message)

def process(lines: list[str]) -> set[Message]:
    # should get called just once per invocation of dciodvfy
    messages = set()
    for line in lines:
        # TODO this was for development and can probably be pdropped
        if line.startswith("dciodvfy"):
            # print(line)
            continue

        level = Level.WARNING

        if line.startswith("Warning"):
            level = Level.WARNING
        if line.startswith("Error"):
            level = Level.ERROR

        message = process_line(line, level)
        if not message.should_drop():
            messages.add(message)

        
    return messages

def main(activity_timepoint_id: str, all_in_series: bool = False):

    conn = psycopg2.connect(dbname="posda_files")
    cur = conn.cursor()


    # short with many errors: 1283 / 6996
    # longer with dupe errors: 1380
    cur.execute("""
    select
        series_instance_uid, storage_path(max(file_id))
    from
        activity_timepoint_file
        natural join file_series
    where
        activity_timepoint_id = %s
        group by 1
    ;
    """, [activity_timepoint_id])


    output = {}

    for series, path in cur:
        # print(series, path)

        out = subprocess.run([
            "dciodvfy",
            "-new",
            path
        ], capture_output=True)

        output[series] = process(out.stderr.decode().split('\n'))

        # break

    # NOTE the below is pretty ugly but it works to re-create Bill's output
    # from the old script, with both series and messages grouped as much
    # as possible.

    # reverse the mapping to group errors by series
    reverse_mapping = defaultdict(set)

    for k, v in output.items():
        for item in v:
            reverse_mapping[item].add(k)

    # freeze the final sets (needed to make them hashable)
    reverse_frozen = {i: frozenset(k) for i, k in reverse_mapping.items()}

    # re-reverse it to group messages by groups-of-series
    final = defaultdict(set)
    for k, v in reverse_frozen.items():
        final[v].add(k)

    def format_message(message):
        return [message.level.name, message.path, message.posda_path, message.formatted_message()]

    # with open(sys.stdout, "w") as outfile:
    if True:
        writer = csv.writer(sys.stdout, dialect=csv.excel)

        # the header
        writer.writerow([
            "series",
            "level",
            "path",
            "posda_path",
            "message"
        ])

        ## Output with no grouping at all
        for series in output:
            for m in output[series]:
                if not m.should_drop():
                    writer.writerow([series] + format_message(m))

        ## Output with gropuing on Series only
        # for k, v in final.items():
        #     series = '\n'.join(list(k))
        #     message = [format_message(m) for m in list(v) if not m.should_drop()]

        #     for m in message:
        #         writer.writerow([series] + m)

        ## Output with grouping in both ways (only series + message is output)
        # for series, messages in final.items():
        #     # turn messages into a single string
        #     messages_str = '\n'.join([m.formatted_full() for m in list(messages)])

        #     series_str = '\n'.join(list(series))

        #     writer.writerow([series_str, messages_str])

def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('activity_timepoint_id', help='the timepoint to process')
    parser.add_argument(
        '--all_in_series', 
        action='store_true',
        help='process all files in every series, instead of just one'
    )

    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()
    main(args.activity_timepoint_id, args.all_in_series)
