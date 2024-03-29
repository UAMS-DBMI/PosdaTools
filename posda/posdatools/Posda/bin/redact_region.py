#!/usr/bin/env python3

import argparse
import tempfile
import sys
import os
import subprocess
import json

DEBUG=False

def dprint(*args, **kwargs):
    if DEBUG:
        print(*args, **kwargs, file=sys.stderr)

def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Redact rectangles from DICOM files. '
                    'Probably only works on CTs or Xrays right now.'
    )
    parser.add_argument('filename')
    parser.add_argument('pixel_offset', type=int, help='')
    parser.add_argument('rows', type=int, help='')
    parser.add_argument('cols', type=int, help='')
    parser.add_argument('bits_allocated', type=int, help='')
    parser.add_argument('bits_stored', type=int, help='')
    parser.add_argument('high_bit', type=int, help='')
    parser.add_argument(
        'photometric_interpretation',
        help='the full string, ie MONOCHROME2'
    )
    parser.add_argument(
        'pixel_representation',
        type=int,
        help='0 = unsigned, 1 = signed'
    )
    parser.add_argument(
        'region',
        help='{x1},{y1} {x2},{y2}. '
        'Upper left corner first, lower right second. Example: 30,80 120,320'
    )
    parser.add_argument('--reassemble-filename', help='If set, a reassembled DICOM file is written here. If ommited, the raw bytes of the pixel data alone are written to stdout')
    parser.add_argument('--debug', action='store_true', help='print a lot of extra messages to stderr')


    return parser.parse_args()

def extract_pixels(filename, pixel_offset):
    dprint(f"Extracting pixels from {filename} at {pixel_offset}")
    outfile = tempfile.NamedTemporaryFile(delete=False)
    with open(filename, "rb") as infile:
        infile.seek(pixel_offset)
        outfile.write(infile.read())
    return outfile.name

def parse_message(message):
    obj = json.loads(message)
    dprint(obj)

    text, (x1, y1, x2, y2, size) = obj

    return {
        'text': text,
        'x1': x1,
        'y1': y1,
        'x2': x2,
        'y2': y2,
        'size': size,
    }


def generate_im_command(args, pixel_filename):
    dprint("Generating commands...")

    rectangle = f"rectangle {args.region}"


    # calculate the color, scale the max value into 8 bit
    max_allowable_value = (2 ** args.bits_stored) - 1
    if args.pixel_representation == 1:
        # it's signed, so drop one more bit off 
        max_allowable_value = (2 ** (args.bits_stored - 1)) - 1
        # max_allowable_value = 2000  # TODO: temp for testing


    # Note: the goal here is to make a black box. For MONOCHROME2,
    #       this should just be 0. But for MONOCHROME1 it needs to
    #       be the max_allowable_value
    # Note2: Hopefully it is also just 0 for RGB

    hex_color = '0000'  # the default

    if args.photometric_interpretation == 'MONOCHROME1':
        hex_color = "{:04X}".format(max_allowable_value)


    color = f"#{hex_color}{hex_color}{hex_color}"

    dprint("max, color:", max_allowable_value, color)

    im_data_type = {
        'MONOCHROME1': 'gray',
        'MONOCHROME2': 'gray',
        'RGB': 'rgb',
    }[args.photometric_interpretation]

    commands = [
        "-size", f"{args.cols}x{args.rows}",
        "-depth", str(args.bits_allocated),
        f"{im_data_type}:{pixel_filename}",
        "-fill", color,
        # "-stroke", "blue",
        "-draw", rectangle
    ]

    return commands

def apply_commands(pixel_filename, im_command, args):
    dprint("Applying commands...")

    output_filename = tempfile.NamedTemporaryFile(delete=False).name


    im_data_type = {
        'MONOCHROME1': 'gray',
        'MONOCHROME2': 'gray',
        'RGB': 'rgb',
    }[args.photometric_interpretation]

    output_commands = [
        '-depth', str(args.bits_allocated),
        f'{im_data_type}:{output_filename}'
    ]

    final_command = ['convert'] + im_command + output_commands
    dprint(final_command)

    subprocess.run(final_command)

    ## a debug script for viewing
    # with open("preview.sh", "w") as out:
    #     out.write(f"display -size {args.cols}x{args.rows} -depth 16 gray:{output_filename}")
    ##
    return output_filename

def reassemble(args, output_filename):
    with open(args.reassemble_filename, "wb") as outfile:
        with open(args.filename, "rb") as source_file:
            header = source_file.read(args.pixel_offset)
        with open(output_filename, "rb") as pixels:
            outfile.write(header)
            outfile.write(pixels.read())

def main():
    global DEBUG

    args = parse_arguments()
    if args.debug:
        DEBUG=True

    # # test writing to args
    # args.something_new = 4
    # print(args.something_new)
    # return

    pixel_filename = extract_pixels(args.filename, args.pixel_offset)
    dprint(pixel_filename)


    im_command = generate_im_command(args, pixel_filename)
    output_filename = apply_commands(pixel_filename, im_command, args)

    if args.reassemble_filename is not None:
        dprint("putting it back together!")
        reassemble(args, output_filename)
    else:
        # print it to stdout
        dprint("Outputting result to stdout! I hope it isn't a terminal!")
        with open(output_filename, "rb") as f:
            sys.stdout.buffer.write(f.read())


    #cleanup
    if not DEBUG:
        os.unlink(pixel_filename)
        os.unlink(output_filename)

def test():
    pixel_filename = extract_pixels(
        '/nas/public/posda/storage/04/79/7c/04797c98f98ad6b3f72cd1de37c70c8f',
        4006
    )

    print(pixel_filename)

if __name__ == '__main__':
    # test()
    main()
