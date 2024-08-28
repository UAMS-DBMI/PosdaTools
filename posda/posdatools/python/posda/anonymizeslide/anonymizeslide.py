#!/usr/bin/python3
#
#  anonymizeslide.py - Delete the label from a whole-slide image.
#
#  Copyright (c) 2007-2013 Carnegie Mellon University
#  Copyright (c) 2011      Google, Inc.
#  Copyright (c) 2014      Benjamin Gilbert
#  Copyright (c) 2023      Quasar Jarosz
#  Copyright (c) 2024      Modified into posda library - S Utecht
#  All rights reserved.
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of version 2 of the GNU General Public License as
#  published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor,
#  Boston, MA 02110-1301 USA.
#

import os
import string
import struct
import sys
import logging
import enum
from configparser import RawConfigParser
from io import StringIO
from glob import glob
from optparse import OptionParser
from posda.tifftags import TiffTag
from openslide import OpenSlide
from tifffile import TiffWriter
from tifffile import TiffFile as Tifffile_tiff
import numpy as np
from PIL import Image


PROG_DESCRIPTION = '''
Delete the slide label from an MRXS, NDPI, or SVS whole-slide image.
'''.strip()
PROG_VERSION = '1.1.1'
DEBUG = False

class Datatype(enum.IntEnum):
    """TIFF tag data types."""

    BYTE = 1
    """8-bit unsigned integer."""
    ASCII = 2
    """8-bit byte with last byte null, containing 7-bit ASCII code."""
    SHORT = 3
    """16-bit unsigned integer."""
    LONG = 4
    """32-bit unsigned integer."""
    RATIONAL = 5
    """Two 32-bit unsigned integers, numerator and denominator of fraction."""
    SBYTE = 6
    """8-bit signed integer."""
    UNDEFINED = 7
    """8-bit byte that may contain anything."""
    SSHORT = 8
    """16-bit signed integer."""
    SLONG = 9
    """32-bit signed integer."""
    SRATIONAL = 10
    """Two 32-bit signed integers, numerator and denominator of fraction."""
    FLOAT = 11
    """Single precision (4-byte) IEEE format."""
    DOUBLE = 12
    """Double precision (8-byte) IEEE format."""
    IFD = 13
    """Unsigned 4 byte IFD offset."""
    UNICODE = 14
    COMPLEX = 15
    LONG8 = 16
    """Unsigned 8 byte integer (BigTIFF)."""
    SLONG8 = 17
    """Signed 8 byte integer (BigTIFF)."""
    IFD8 = 18
    """Unsigned 8 byte IFD offset (BigTIFF)."""


# TIFF tags
# IMAGE_DESCRIPTION = 270
# STRIP_OFFSETS = 273
# STRIP_BYTE_COUNTS = 279

# TODO these two need to be addded to the TiffTag enum
NDPI_MAGIC = 65420
NDPI_SOURCELENS = 65421

# Format headers
LZW_CLEARCODE = b'\x80'
JPEG_SOI = b'\xff\xd8'
UTF8_BOM = b'\xef\xbb\xbf'

# MRXS
MRXS_HIERARCHICAL = 'HIERARCHICAL'
MRXS_NONHIER_ROOT_OFFSET = 41


class UnrecognizedFile(Exception):
    pass

class TiffFile:
    def __init__(self, path):
        self._file = open(path, 'r+b')

        # Check header, decide endianness
        endian = self._file.read(2)
        logging.debug(f"Endian magic: {endian}")
        if endian == b'II':
            self._fmt_prefix = '<'
        elif endian == b'MM':
            self._fmt_prefix = '>'
        else:
            raise UnrecognizedFile

        # Check TIFF version
        self._bigtiff = False
        self._ndpi = False
        version = self.read_fmt('H')
        if version == 42:
            pass
        elif version == 43:
            self._bigtiff = True
            logging.debug("Detected BigTIFF file")
            magic2, reserved = self.read_fmt('HH')
            if magic2 != 8 or reserved != 0:
                raise UnrecognizedFile
        else:
            raise UnrecognizedFile

        # Read directories
        self.directories = []
        while True:
            # the offset that pointed to this IFD
            in_pointer_offset = self._file.tell()
            directory_offset = self.read_fmt('D')
            logging.debug(f"next directory at: {directory_offset}")
            if directory_offset == 0:
                break
            self._file.seek(directory_offset)
            logging.debug("creating TiffDirectory")
            directory = TiffDirectory(self, len(self.directories),
                    in_pointer_offset)
            if not self.directories and not self._bigtiff:
                # Check for NDPI.  Because we don't know we have an NDPI file
                # until after reading the first directory, we will choke if
                # the first directory is beyond 4 GB.
                if NDPI_MAGIC in directory.entries:
                    logging.debug('Enabling NDPI mode.')
                    self._ndpi = True
            self.directories.append(directory)
        if not self.directories:
            raise IOError('No directories')

    def _convert_format(self, fmt):
        # Format strings can have special characters:
        # y: 16-bit   signed on little TIFF, 64-bit   signed on BigTIFF
        # Y: 16-bit unsigned on little TIFF, 64-bit unsigned on BigTIFF
        # z: 32-bit   signed on little TIFF, 64-bit   signed on BigTIFF
        # Z: 32-bit unsigned on little TIFF, 64-bit unsigned on BigTIFF
        # D: 32-bit unsigned on little TIFF, 64-bit unsigned on BigTIFF/NDPI
        if self._bigtiff:
            fmt = fmt.translate(str.maketrans('yYzZD', 'qQqQQ'))
        elif self._ndpi:
            fmt = fmt.translate(str.maketrans('yYzZD', 'hHiIQ'))
        else:
            fmt = fmt.translate(str.maketrans('yYzZD', 'hHiII'))
        return self._fmt_prefix + fmt

    def fmt_size(self, fmt):
        return struct.calcsize(self._convert_format(fmt))

    def near_pointer(self, base, offset):
        # If NDPI, return the value whose low-order 32-bits are equal to
        # @offset and which is within 4 GB of @base and below it.
        # Otherwise, return offset.
        if self._ndpi and offset < base:
            seg_size = 1 << 32
            offset += ((base - offset) // seg_size) * seg_size
        return offset

    def read_fmt(self, fmt, force_list=False):
        logging.debug(f"read_fmt(fmt={fmt}, force_list={force_list})")
        fmt = self._convert_format(fmt)
        bytes_read = self._file.read(struct.calcsize(fmt))
        logging.debug(f"read {len(bytes_read)} bytes")
        if len(bytes_read) == 0:
            logging.debug(self._file.tell())
        vals = struct.unpack(fmt, bytes_read)
        if len(vals) == 1 and not force_list:
            return vals[0]
        else:
            return vals

    def write_fmt(self, fmt, *args):
        fmt = self._convert_format(fmt)
        self.write(struct.pack(fmt, *args))

    # Pretend to be a file
    def read(self, *args, **kwargs):
        return self._file.read(*args, **kwargs)

    def write(self, *args, **kwargs):
        return self._file.write(*args, **kwargs)

    def seek(self, *args, **kwargs):
        return self._file.seek(*args, **kwargs)

    def tell(self, *args, **kwargs):
        return self._file.tell(*args, **kwargs)


class TiffDirectory:
    def __init__(self, fh, number, in_pointer_offset):
        logging.debug(f"TiffDirectory init({number}, {in_pointer_offset})")
        self.entries = {}
        count = fh.read_fmt('Y')
        logging.debug(f"This Directory has {count} entries")

        # TODO just for debugging, move the pointer ahead
        # end_of_ifd = fh.tell() + (count * 12)
        # logging.debug(f"moving to end of ifd: {end_of_ifd}")
        # fh.seek(end_of_ifd)

        for _ in range(count):
            entry = TiffEntry(fh)
            self.entries[entry.tag] = entry
        self._in_pointer_offset = in_pointer_offset
        self._out_pointer_offset = fh.tell()
        self._fh = fh
        self._number = number

    def delete(self, expected_prefix=None):
        # Get strip offsets/lengths
        try:
            offsets = self.entries[TiffTag.StripOffsets].value()
            lengths = self.entries[TiffTag.StripByteCounts].value()
        except KeyError:
            raise IOError('Directory is not stripped')

        # Wipe strips
        for offset, length in zip(offsets, lengths):
            offset = self._fh.near_pointer(self._out_pointer_offset, offset)
            logging.debug('Zeroing %d for %d', offset, length)
            self._fh.seek(offset)
            if expected_prefix:
                buf = self._fh.read(len(expected_prefix))
                if buf != expected_prefix:
                    raise IOError('Unexpected data in image strip')
                self._fh.seek(offset)
            self._fh.write(b'\0' * length)

        # in_pointer_offset = location of the pointer to this IFD
        # out_pointer_offset = location of the pointer to the NEXT IFD

        # Remove directory
        #print('Deleting directory %d @ %d', self._number, self._in_pointer_offset)
        self._fh.seek(self._out_pointer_offset)
        out_pointer = self._fh.read_fmt('D')
        #print('Read out_pointer as %d', out_pointer)
        self._fh.seek(self._in_pointer_offset)
        #print('Writing it over in_pointer at %d', self._in_pointer_offset)
        # self._fh.write_fmt('D', out_pointer)
        self._fh.write_fmt('D', 0)

    def replace(self, new_data):
        descObj = self.entries[TiffTag.ImageDescription]
        old = descObj.value()
        oldLen = descObj.my_data_length()
        newLen = len(new_data.encode('utf-8'))
        lenDiff = oldLen - newLen
        #print('oldLen:{} newLen:{}, lenDiff: {}'.format(oldLen, newLen, lenDiff))
        if lenDiff < 0:
            raise IOError('Edit data larger than data strip')

        self._fh.seek(descObj.my_data_start())
        bytesToWrite = new_data.encode('utf-8')
        bytesToWrite = bytesToWrite + (b'\0' * lenDiff)
        if oldLen == len(bytesToWrite):
            self._fh.write(bytesToWrite)
            #print('replace completed')
        else:
            print('oldLen not same as new: {} vs {}'.format(oldLen,len(bytesToWrite)))
            print('replace failed')



class TiffEntry:
    def __init__(self, fh):
        self.start = fh.tell()
        self.tag, self.type, self.count, self.value_offset = \
                fh.read_fmt('HHZZ')
        self._fh = fh

        if self.type == Datatype.ASCII:
            self.item_fmt = 'c'
        elif self.type == Datatype.SHORT:
            self.item_fmt = 'H'
        elif self.type == Datatype.LONG:
            self.item_fmt = 'I'
        elif self.type == Datatype.LONG8:
            self.item_fmt = 'Q'
        elif self.type == Datatype.FLOAT:
            self.item_fmt = 'f'
        elif self.type == Datatype.DOUBLE:
            self.item_fmt = 'd'


    def my_data_start(self):
        fmt = '%d%s' % (self.count, self.item_fmt)
        len = self._fh.fmt_size(fmt)
        if len <= self._fh.fmt_size('Z'):
            # Inline value
            return self.start + self._fh.fmt_size('HHZ')
        else:
            # Out-of-line value
            return self._fh.near_pointer(self.start, self.value_offset)

    def my_data_length(self):
        fmt = '%d%s' % (self.count, self.item_fmt)
        return int(self._fh.fmt_size(fmt))

    def value(self):


        fmt = '%d%s' % (self.count, self.item_fmt)
        len = self._fh.fmt_size(fmt)
        if len <= self._fh.fmt_size('Z'):
            # Inline value
            self._fh.seek(self.start + self._fh.fmt_size('HHZ'))
        else:
            # Out-of-line value
            self._fh.seek(self._fh.near_pointer(self.start, self.value_offset))
        items = self._fh.read_fmt(fmt, force_list=True)
        if self.type == Datatype.ASCII:
            if items[-1] != b'\0':
                raise ValueError('String not null-terminated')
            return b''.join(items[:-1])
        else:
            return items


def remove_macro_aperio_svs(filename):
    #print('In the do_aperio_svs')
    fh = TiffFile(filename)
    # Check for SVS file
    try:
        desc0 = fh.directories[0].entries[TiffTag.ImageDescription].value()
        if not desc0.startswith(b'Aperio'):
            raise UnrecognizedFile
    except KeyError:
        raise UnrecognizedFile
    deleted_macro = False
    for directory in fh.directories:
        lines = directory.entries[TiffTag.ImageDescription].value().splitlines()
        # the macro should be the very last layer
        if len(lines) >= 2 and lines[1].startswith(b'macro '):
            #print("Found macro")
            directory.delete(expected_prefix=JPEG_SOI)
            deleted_macro = True
    if deleted_macro is False:
        print("macro not removed")

def remove_label_aperio_svs(filename):
    #print('In the do_aperio_svs')
    fh = TiffFile(filename)
    # Check for SVS file
    try:
        desc0 = fh.directories[0].entries[TiffTag.ImageDescription].value()
        if not desc0.startswith(b'Aperio'):
            raise UnrecognizedFile
    except KeyError:
        raise UnrecognizedFile
    deleted_label = False
    for directory in fh.directories:
        lines = directory.entries[TiffTag.ImageDescription].value().splitlines()
        # the macro should be the very last layer
        if len(lines) >= 2 and lines[1].startswith(b'label '):
            #print("Found label")
            directory.delete(expected_prefix=LZW_CLEARCODE)
            deleted_label = True
    if deleted_label is False:
        print("label not removed")

def getImageDesc(directory):
    img_desc_dict = {}
    lines = directory.entries[TiffTag.ImageDescription].value().splitlines()
    for l in lines:
        split_desc = l.decode('utf-8').split('|')
        for tag_key, value in enumerate(split_desc):
            split_entry = value.split(' = ')
            img_desc_dict[split_entry[0]] = split_entry[1] if len(split_entry) > 1 else ''
    return img_desc_dict

def editImageDesc(filename):
    to_change = 0
    fh = TiffFile(filename)

    try:
        desc0 = fh.directories[0].entries[TiffTag.ImageDescription].value()
        if not desc0.startswith(b'Aperio'):
            raise UnrecognizedFile
    except KeyError:
        raise UnrecognizedFile

    for directory in fh.directories:
        desc_dict = getImageDesc(directory)
        #print("desc_dict {}".format(desc_dict))
        for tag in desc_dict:
            if tag in ('User','Filename','ImageID'):
                #print("bad tag")
                desc_dict[tag]  = '0'
                to_change = to_change+1
        if to_change != 0:
            new_img_desc = combine_image_desc(desc_dict)
            directory.replace(new_img_desc)
            print('{} elements of description edited'.format(to_change))
            to_change = 0

def blackout(im1, l, dims, coords):
    im = Image.new("RGB", (im1.size[0], im1.size[1]))
    im.paste(im1)

    list_dims = list(dims)
    scale = list_dims[-1] / list_dims[l]
    if scale > 0:
        x = int(int(coords[0]) * scale)
        y = int(int(coords[1]) * scale)
        w = int(int(coords[2]) * scale)
        h = int(int(coords[3]) * scale)

        print("X,Y: ({},{})".format(x,y))
        print("W,H: ({},{})".format(w,h))
        img2 = Image.new('RGB', (w ,h ))
        im.paste(img2, (x,y))
    return im

def is_increasing(sequence):
    return all(earlier < later for earlier, later in zip(sequence, sequence[1:]))

def redactPixels(filepath, ogpath, coord_set):
    coordinates = coord_set.split(',')
    new_pixels = {}
    filetype = OpenSlide.detect_format(filepath)
    try:
        myImage = OpenSlide(ogpath)
        layers = myImage.level_count
        if is_increasing(myImage.level_downsamples):
            for l in range(layers):
                print("Layer {}".format(l))
                downsampled_dimensions = myImage.level_dimensions[l]
                if l > 1: #skip label and thumbnail
                    im = myImage.read_region((0, 0), l, downsampled_dimensions)
                    img1 = im.convert('RGB')
                    new_pixels[l] = np.array(blackout(img1,l,myImage.level_downsamples,coordinates))
    except:
        print("File at {} is not recognized as an image file".format(ogpath))
        pass
    return saveNew(filepath, ogpath, new_pixels)

def saveNew(filepath, ogpath, pixel_data_by_layer):
    if pixel_data_by_layer:
        strE = '' + str(filepath) + '_redacted.tiff'
        tw = TiffWriter(strE, bigtiff=True)
        og = Tifffile_tiff(ogpath)
        fullRezOkay = False
        print('layers expecting modification {}'.format(pixel_data_by_layer.keys()))
        for i, page in enumerate(og.pages):
            if (page.size < 5000000000 or fullRezOkay):
                # Replace the modified data for the specific layer, keep others intact
                extratags = [
                    (tag.code, tag.dtype, tag.count, tag.value)
                    for tag in page.tags.values()
                ]
                if i in pixel_data_by_layer.keys():
                    print('writing modified layer')
                    tw.write(
                        pixel_data_by_layer[i],  # The modified layer data
                        photometric=page.photometric,
                        compression=page.compression,
                        planarconfig=page.planarconfig,
                        tile=(page.tilewidth, page.tilelength) if page.is_tiled else None,
                        description='Redacted image derived from original|:{}'.format(page.description),
                        extratags=extratags,  # Include all extracted tags
                        )
                else:
                    print('writing original layer layer')
                    tw.write(
                        page.asarray(),  # Unmodified layers
                        photometric=page.photometric,
                        compression=page.compression,
                        planarconfig=page.planarconfig,
                        tile=(page.tilewidth, page.tilelength) if page.is_tiled else None,
                        description='Redacted image derived from original| :{}'.format(page.description),
                        extratags=extratags,  # Include all extracted tags
                        )
            else:
                print('Original layer {} was skipped due to size.'.format(i))
        print('Redaction Succesful: new file: {}'.format(strE))
        return strE
    else:
        print('*** Redaction FAILED: returning original file: {}  ***'.format(ogpath))
        return ogpath

#from MR
def combine_image_desc(desc_dict):
    image_desc = ''
    for e in desc_dict.keys():
        if desc_dict[e] == '' or  desc_dict[e] == '':
            image_desc = image_desc + e  + '|'
        else:
            image_desc = image_desc + e + ' = ' + desc_dict[e] + '|'
    #print('Combine complete: {}'.format(image_desc))
    return image_desc



def anonymize(filepaths,edit_type):
    #print("removing slide")
    for filename in filepaths:
        try:
            if edit_type == '1':
                #print("removing macro")
                remove_macro_aperio_svs(filename)
            elif edit_type == '2':
                #print("removing layer")
                remove_label_aperio_svs(filename)
            elif edit_type == '3':
                #print("removing ImageDesc")
                editImageDesc(filename)
            #4 is remove whole file, no edit
            #5 is handled in redactPixels

        except Exception as e:
            print('%s: %s' % (filename, str(e)), file=sys.stderr)
