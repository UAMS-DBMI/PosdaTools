from struct import unpack, pack
import io as cStringIO

from .magic import magic
from .debug import debug

FIRST = True

def store(data, filename):
    global FIRST
    FIRST = True

    fh = open(filename, 'wb')

    fh.write(b'pst0') # main header magic

    # version , arch / byte order magic
    version = 10
    fh.write(magic['SX_REF'])
    fh.write(pack('B', version))

    arch = b'12345678'
    byteorder = '<'
    fh.write(pack('B', len(arch)))
    fh.write(arch)

    # Write the special magic
    # purpose of this is unknown. deserialize ignores it
    fh.write(b'\x04\x08\x08\x08')

    store_item(fh, data)

    fh.close()


def store_item(fh, item):
    # determine item type
    # DEBUG assume it is an int if it is not a list
    if isinstance(item, list):
        store_list(fh, item)
    elif isinstance(item, dict):
        store_dict(fh, item)
    elif isinstance(item, int):
        store_int(fh, item)
    elif isinstance(item, float):
        store_double(fh, item)
    elif item is None:
        store_none(fh)
    else: # default to string
        store_string(fh, item)


def store_list(fh, items):
    global FIRST
    if FIRST:
        FIRST = False
    else:
        fh.write(magic['SX_REF'])

    fh.write(magic['SX_ARRAY'])

    list_size = len(items)

    fh.write(pack('<I', list_size))

    for i in items:
        store_item(fh, i)


def store_dict(fh, items):
    global FIRST
    if FIRST:
        FIRST = False
    else:
        fh.write(magic['SX_REF'])
    fh.write(magic['SX_HASH'])

    # write the length of dict
    dict_len = len(items)
    _write_size(fh, dict_len)

    # for each item:
    for key, value in items.items():
    #   write the value object (by calling store_item)
        store_item(fh, value)
    #   write the key length
        key = str(key)
        _write_size(fh, len(key))
    #   write the key data (can only be a string!)
        fh.write(key.encode('utf-8'))


def store_int(fh, item):
    fh.write(magic['SX_INTEGER'])
    fh.write(pack('<Q', item))


def store_double(fh, item):
    fh.write(magic['SX_DOUBLE'])
    fh.write(pack('<d', item))


def store_string(fh, item):
    item = str(item)  # in case it wasn't already
    fh.write(magic['SX_SCALAR'])

    size = len(item)
    fh.write(pack('B', size))

    fh.write(item.encode('utf-8'))
 

def store_none(fh):
    fh.write(magic['SX_UNDEF'])
