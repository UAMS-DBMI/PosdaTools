#!/usr/bin/env python3

import fire
import json
import csv


def convert_to_csv(input_filename, output_filename, truncate_path=None):
    obj = {}

    with open(input_filename) as infile:
        with open(output_filename, 'w') as outfile:
            writer = csv.writer(outfile)

            for line in infile:
                line_obj = json.loads(line)
                filename = line_obj['filename']
                if truncate_path is not None:
                    filename = filename.replace(truncate_path, '')

                writer.writerow([filename])
    


if __name__ == '__main__':
    fire.Fire(convert_to_csv)
