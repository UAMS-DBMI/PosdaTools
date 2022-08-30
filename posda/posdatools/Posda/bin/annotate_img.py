#!/usr/bin/env python3

import argparse
import tempfile
import sys
import os
import subprocess
import json
from dataclasses import dataclass

from pprint import pprint

DEBUG=False


@dataclass
class Drawable:
    pass

@dataclass
class Box(Drawable):
    x: int
    y: int
    width: int
    height: int
    color: str

@dataclass
class Text(Drawable):
    message: str
    x1: int
    x2: int
    y1: int
    y2: int
    size: int


def dprint(*args, **kwargs):
    if DEBUG:
        print(*args, **kwargs, file=sys.stderr)

def parse_arguments():
    parser = argparse.ArgumentParser(
        description='Add text and box annotations to DICOM files. '
                    'Only works on ~16 bit monochrome images.'
    )
    parser.add_argument('filename')
    parser.add_argument('pixel_offset', type=int, help='')
    parser.add_argument('rows', type=int, help='')
    parser.add_argument('cols', type=int, help='')
    parser.add_argument('bits_allocated', type=int, help='')
    parser.add_argument('bits_stored', type=int, help='')
    parser.add_argument('high_bit', type=int, help='')
    parser.add_argument('photometric_interpretation', help='the full string, ie MONOCHROME2')
    parser.add_argument('pixel_representation', type=int, help='0 = unsigned, 1 = signed')
    parser.add_argument(
        'command_json',
        help='A list of box or text objects in json format'
    )
    parser.add_argument('--reassemble-filename', help='If set, a reassembled DICOM file is written here. If ommited, the raw bytes of the pixel data lone are written to stdout')
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

def generate_im_command_for_box(box, args, pixel_filename):
    dprint("Generating commands...")

    x1 = box.x
    y1 = box.y
    x2 = box.x + box.width
    y2 = box.y + box.height

    # TODO: actually use the color specified in the Box

    rectangle = f"rectangle {x1},{y1} {x2},{y2}"
    dprint(rectangle)


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

def generate_im_command(msg, args, pixel_filename):
    dprint("Generating commands...")
    # msg = parse_message(args.message)

    #Looks like, given this format, we will have to guess at a point size
    # based on the expected width of the drawing and the actual width
    # of the written text :-|


    # calculate the color, scale the max value into 8 bit
    max_allowable_value = (2 ** args.bits_stored) - 1
    if args.pixel_representation == 1:
        # it's signed, so drop one more bit off 
        max_allowable_value = (2 ** (args.bits_stored - 1)) - 1
        # max_allowable_value = 2000  # TODO: temp for testing

    hex_color = "{:04X}".format(max_allowable_value)

    # in mono1, white is just 0, so it's easy.
    if args.photometric_interpretation == 'MONOCHROME1':
        hex_color = '0000'



    color = f"#{hex_color}{hex_color}{hex_color}"

    dprint("max, color:", max_allowable_value, color)

    commands = [
        "-size", f"{args.cols}x{args.rows}",
        "-depth", str(args.bits_allocated),
        f"gray:{pixel_filename}",
        "-fill", color,
        # "-stroke", "blue",
        "-pointsize", f"{msg.size}",
        "-gravity", "NorthWest",
        "+antialias",
        "-annotate", f"+{msg.x1}+{msg.y1}", msg.message,
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

    obj = json.loads(args.command_json)
    cmdlist = parse_commands(obj)

    pixel_filename = extract_pixels(args.filename, args.pixel_offset)
    dprint(pixel_filename)


    files_to_cleanup = [pixel_filename]

    for command in cmdlist:
        if isinstance(command, Text):
            im_command = generate_im_command(command, args, pixel_filename)
        else:
            im_command = generate_im_command_for_box(command, args, pixel_filename)

        pixel_filename = apply_commands(pixel_filename, im_command, args)
        files_to_cleanup.append(pixel_filename)

    if args.reassemble_filename is not None:
        dprint("putting it back together!")
        reassemble(args, pixel_filename)
    else:
        # print it to stdout
        dprint("Outputting result to stdout! I hope it isn't a terminal!")
        with open(pixel_filename, "rb") as f:
            sys.stdout.buffer.write(f.read())


    #cleanup
    if not DEBUG:
        for f in files_to_cleanup:
            os.unlink(f)

def test():
    global DEBUG

    args = parse_arguments()
    if args.debug:
        DEBUG=True

    # print(args)

    obj = json.loads(args.command_json)
    cmdlist = parse_commands(obj)
    pprint(cmdlist)

def parse_commands(cmdlist):
    result = []
    for cmd in cmdlist:
        pcmd = parse_command(cmd)
        result.append(pcmd)

    return result

def parse_command(cmd):
    for cmd_name in cmd:
        commands = cmd[cmd_name]
        if cmd_name == 'box':
            box = Box(*commands)
            return box
        if cmd_name == 'text':
            text = Text(*commands)
            return text

        raise ValueError(f"Unknown object: {cmd_name}")

if __name__ == '__main__':
    main()
    # test()
