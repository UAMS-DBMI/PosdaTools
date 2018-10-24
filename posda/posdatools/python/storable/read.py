#
# License
#
# python storable is distributed under the zlib/libpng license, which is OSS
# (Open Source Software) compliant.
#
# Copyright (C) 2009 Tim Aerts
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgment in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#
# Tim Aerts <aardbeiplantje@gmail.com>
#

from struct import unpack, pack
import io as cStringIO

from .debug import debug


def _read_size(fh, cache):
    return unpack(cache['size_unpack_fmt'], fh.read(4))[0]

def _write_size(fh, size):
    fh.write(pack('<I', size))   

def SX_IGNORE():
    print("SX_IGNORE")
    pass

def SX_OBJECT(fh, cache):
    # idx's are always big-endian dumped by storable's freeze/nfreeze I think
    i = unpack('>I', fh.read(4))[0]
    cache['has_sx_object'] = True
    return (0, i)

def SX_LSCALAR(fh, cache):
    v = fh.read(_read_size(fh, cache))
    return v

def SX_LUTF8STR(fh, cache):
    v = fh.read(_read_size(fh, cache)).decode('utf-8')
    return v

def SX_ARRAY(fh, cache):
    data = []
    array_size = _read_size(fh, cache)

    for i in range(0, array_size):
        data.append(process_item(fh, cache))

    return data

def SX_HASH(fh, cache):
    data = {}
    for i in range(0,_read_size(fh, cache)):
        value = process_item(fh, cache)
        # print("the value was: {}".format(value))
        # the key will always have to be a string
        key   = fh.read(_read_size(fh, cache)).decode('utf-8')
        data[key] = value

    return data

def SX_REF(fh, cache):
    return process_item(fh, cache)

def SX_UNDEF(fh, cache):
    return None

def SX_INTEGER(fh, cache):
    return unpack(cache['int_unpack_fmt'], fh.read(8))[0]

def SX_DOUBLE(fh, cache):
    return unpack(cache['double_unpack_fmt'], fh.read(8))[0]

def SX_BYTE(fh, cache):
    # -128 why? Because this is actually a signed byte?
    # is there not a format for unpack to read a signed byte?
    return unpack('B', fh.read(1))[0] - 128

def SX_NETINT(fh, cache):
    return unpack('>I', fh.read(4))[0]

def SX_SCALAR(fh, cache):
    # scalar seems to normally be a string
    # but could it be a number? I think so?
    size = unpack('B', fh.read(1))[0]
    return fh.read(size).decode('utf-8')

def SX_UTF8STR(fh, cache):
    v = fh.read(_read_size(fh, cache)).decode('utf-8')
    return v

def SX_TIED_ARRAY(fh, cache):
    return process_item(fh, cache)

def SX_TIED_HASH(fh, cache):
    return SX_TIED_ARRAY(fh, cache)

def SX_TIED_SCALAR(fh, cache):
    return SX_TIED_ARRAY(fh, cache)

def SX_SV_UNDEF(fh, cache):
    return None

def SX_BLESS(fh, cache):
    size = unpack('B', fh.read(1))[0]
    package_name = fh.read(size)
    cache['classes'].append(package_name)
    return process_item(fh, cache)

def SX_IX_BLESS(fh, cache):
    indx = unpack('B', fh.read(1))[0]
    package_name = cache['classes'][indx]
    return process_item(fh, cache)

def SX_OVERLOAD(fh, cache):
    return process_item(fh, cache)

def SX_TIED_KEY(fh, cache):
    data = process_item(fh, cache)
    key  = process_item(fh, cache)
    return data
    
def SX_TIED_IDX(fh, cache):
    data = process_item(fh, cache)
    # idx's are always big-endian dumped by storable's freeze/nfreeze I think
    indx_in_array = unpack('>I', fh.read(4))[0]
    return data

def SX_HOOK(fh, cache):
    flags = unpack('B', fh.read(1))[0]

    while flags & int(0x40):   # SHF_NEED_RECURSE
        #print("SHF_NEED_RECURSE")
        dummy = process_item(fh, cache)
        #print(dummy)
        flags = unpack('B', fh.read(1))[0]
        #print("flags:"+str(flags))

    #print("recursive done")

    if flags & int(0x20):   # SHF_IDX_CLASSNAME
        #print("SHF_IDX_CLASSNAME")
        #print("where:"+str(fh.tell()))
        if flags & int(0x04):   # SHF_LARGE_CLASSLEN
            #print("SHF_LARGE_CLASSLEN")
            # TODO: test
            indx = unpack('>I', fh.read(4))[0]
        else:
            indx = unpack('B', fh.read(1))[0]
        #print("classindx:"+str(indx))
        package_name = cache['classes'][indx]
    else:
        #print("where:"+str(fh.tell()))
        if flags & int(0x04):   # SHF_LARGE_CLASSLEN
            #print("SHF_LARGE_CLASSLEN")
            # TODO: test
            # FIXME: is this actually possible?
            class_size = _read_size(fh, cache)
        else:
            class_size = unpack('B', fh.read(1))[0]
            #print("size:"+str(class_size))

        package_name = fh.read(class_size)
        cache['classes'].append(package_name)
        #print("size:"+str(class_size)+",package:"+str(package_name))

    arguments = {}

    str_size = 0
    if flags & int(0x08):   # SHF_LARGE_STRLEN
        #print("SHF_LARGE_STRLEN")
        str_size = _read_size(fh, cache)
    else:
        #print("where:"+str(fh.tell()))
        str_size = unpack('B', fh.read(1))[0]

    if str_size:
        frozen_str = fh.read(str_size)
        #print("size:"+str(str_size)+",frozen_str:"+str(frozen_str))
        arguments[0] = frozen_str

    list_size = 0
    if flags & int(0x80):   # SHF_HAS_LIST
        #print("SHF_HAS_LIST")
        if flags & int(0x10):   # SHF_LARGE_LISTLEN
            #print("SHF_LARGE_LISTLEN")
            #print("where:"+str(fh.tell()))
            list_size = _read_size(fh, cache)
        else:
            list_size = unpack('B', fh.read(1))[0]


    #print("list_size:"+str(list_size))
    for i in range(0,list_size):
        indx_in_array = unpack('>I', fh.read(4))[0]
        #print("indx:"+str(indx_in_array))
        if indx_in_array in cache['objects']:
            arguments[i+1] = cache['objects'][indx_in_array]
        else:
            arguments[i+1] = None

    # FIXME: implement the real callback STORABLE_thaw() still, for now, just
    # return the dictionary 'arguments' as data
    type = flags & int(0x03) # SHF_TYPE_MASK 0x03
    #print("flags:"+str(type))
    data = arguments
    if type == 3:  # SHT_EXTRA
        # TODO
        #print("SHT_EXTRA")
        pass
    if type == 0:  # SHT_SCALAR
        # TODO
        #print("SHT_SCALAR")
        pass
    if type == 1:  # SHT_ARRAY
        # TODO
        #print("SHT_ARRAY")
        pass
    if type == 2:  # SHT_HASH
        # TODO
        #print("SHT_HASH")
        pass


    return data

def SX_FLAG_HASH(fh, cache):
    # TODO: NOT YET IMPLEMENTED!!!!!!
    #print("SX_FLAG_HASH:where:"+str(fh.tell()))
    flags = unpack('B', fh.read(1))[0]
    size  = _read_size(fh, cache)
    #print("size:"+str(size))
    #print("flags:"+str(flags))
    data = {}
    for i in range(0,size):
        value = process_item(fh, cache)
        flags = unpack('B', fh.read(1))[0]
        keysize = _read_size(fh, cache)
        key = None
        if keysize:
            key = fh.read(keysize)
        data[key] = value

    return data

# *AFTER* all the subroutines
engine = {
    b'\x00': SX_OBJECT,      # ( 0): Already stored object
    b'\x01': SX_LSCALAR,     # ( 1): Scalar (large binary) follows (length, data)
    b'\x02': SX_ARRAY,       # ( 2): Array forthcoming (size, item list)
    b'\x03': SX_HASH,        # ( 3): Hash forthcoming (size, key/value pair list)
    b'\x04': SX_REF,         # ( 4): Reference to object forthcoming
    b'\x05': SX_UNDEF,       # ( 5): Undefined scalar
    b'\x06': SX_INTEGER,     # ( 6): Undefined scalar
    b'\x07': SX_DOUBLE,      # ( 7): Double forthcoming
    b'\x08': SX_BYTE,        # ( 8): (signed) byte forthcoming
    b'\x09': SX_NETINT,      # ( 9): Integer in network order forthcoming
    b'\x0a': SX_SCALAR,      # (10): Scalar (binary, small) follows (length, data)
    b'\x0b': SX_TIED_ARRAY,  # (11): Tied array forthcoming
    b'\x0c': SX_TIED_HASH,   # (12): Tied hash forthcoming
    b'\x0d': SX_TIED_SCALAR, # (13): Tied scalar forthcoming
    b'\x0e': SX_SV_UNDEF,    # (14): Perl's immortal PL_sv_undef
    b'\x11': SX_BLESS,       # (17): Object is blessed
    b'\x12': SX_IX_BLESS,    # (18): Object is blessed, classname given by index
    b'\x13': SX_HOOK,        # (19): Stored via hook, user-defined
    b'\x14': SX_OVERLOAD,    # (20): Overloaded reference
    b'\x15': SX_TIED_KEY,    # (21): Tied magic key forthcoming
    b'\x16': SX_TIED_IDX,    # (22): Tied magic index forthcoming
    b'\x17': SX_UTF8STR,     # (23): UTF-8 string forthcoming (small)
    b'\x18': SX_LUTF8STR,    # (24): UTF-8 string forthcoming (large)
    b'\x19': SX_FLAG_HASH,   # (25): Hash with flags forthcoming (size, flags, key/flags/value triplet list)
}

exclude_for_cache = dict({
    b'\x00':True, b'\x0b':True, b'\x0c':True, b'\x0d':True, b'\x11':True, b'\x12':True
})

def handle_sx_object_refs(cache, data):
    iterateelements = None
    if type(data) is list:
        iterateelements = enumerate(iter(data))
    elif type(data) is dict:
        iterateelements = iter(list(data.items()))
    else:
        return

    for k,item in iterateelements:
        if type(item) is list or type(item) is dict:
            handle_sx_object_refs(cache, item)
        if type(item) is tuple:
            data[k] = cache['objects'][item[1]]
    return data

def process_item(fh, cache):
    magic_type = fh.read(1)
    debug("Magic: ", magic_type, "\t", engine[magic_type].__name__)
    # print("Magic: ", magic_type)

    if magic_type not in exclude_for_cache:
        if magic_type == b'\n':
            # print("W T F???")
            # print(engine[magic_type])
            # print(engine[b'\n'])
            pass

        i = cache['objectnr']
        cache['objectnr'] = cache['objectnr']+1
        cache['objects'][i] = engine[magic_type](fh, cache)

        return cache['objects'][i]
    else:
        # print("process_item returning from engine: {}".format(magic_type))
        return engine[magic_type](fh, cache)

def thaw(frozen_data):
    fh = cStringIO.BytesIO(frozen_data)
    data = deserialize(fh);
    fh.close();
    return data

def retrieve(file):
    fh = open(file, 'rb')
    ignore = fh.read(4)
    data = None
    if ignore == b'pst0':
        data = deserialize(fh)
    fh.close()
    return data



def deserialize(fh):
    magic = fh.read(1)
    byteorder = '>'
    if magic == b'\x05':
        version = fh.read(1)
        debug("OK:nfreeze")
    if magic == b'\x04':
        version = fh.read(1)
        size  = unpack('B', fh.read(1))[0]
        archsize = fh.read(size)
        debug("Version: ", version)
        debug("Archsize ", archsize)

        # 32-bit ppc:     4321
        # 32-bit x86:     1234
        # 64-bit x86_64:  12345678

        if archsize == b'1234' or archsize == b'12345678':
            byteorder = '<'
        else:
            byteorder = '>'

        somethingtobeinvestigated = fh.read(4)
        debug("unknown 4byte magic: ", somethingtobeinvestigated)

    #print('version:'+str(unpack('B', version)[0]));
    cache = { 
        'objects'           : {},
        'objectnr'          : 0,
        'classes'           : [],
        'has_sx_object'     : False,
        'size_unpack_fmt'   : byteorder + 'I',
        'int_unpack_fmt'    : byteorder + 'Q',
        'double_unpack_fmt' : byteorder + 'd'
    }
    data = process_item(fh, cache)

    if cache['has_sx_object']:
        handle_sx_object_refs(cache, data)

    return data
