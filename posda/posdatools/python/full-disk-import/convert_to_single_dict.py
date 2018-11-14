#!/usr/bin/env python3

import fire
import json


def convert_to_dict(input_filename, output_filename):
    obj = {}

    with open(input_filename) as infile:
        for line in infile:
            line_obj = json.loads(line)
            filename = line_obj['filename']
            del line_obj['filename']
            obj[filename] = line_obj


    # adjust it here

    
    with open(output_filename, 'w') as outfile:
        json.dump(obj, outfile, indent=2)


if __name__ == '__main__':
    fire.Fire(convert_to_dict)
