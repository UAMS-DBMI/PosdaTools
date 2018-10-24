magic = {
 'SX_OBJECT':        b'\x00',  # ( 0): Already stored object
 'SX_LSCALAR':       b'\x01',  # ( 1): Scalar (large binary) follows (length, data)
 'SX_ARRAY':         b'\x02',  # ( 2): Array forthcoming (size, item list)
 'SX_HASH':          b'\x03',  # ( 3): Hash forthcoming (size, key/value pair list)
 'SX_REF':           b'\x04',  # ( 4): Reference to object forthcoming
 'SX_UNDEF':         b'\x05',  # ( 5): Undefined scalar
 'SX_INTEGER':       b'\x06',  # ( 6): Undefined scalar
 'SX_DOUBLE':        b'\x07',  # ( 7): Double forthcoming
 'SX_BYTE':          b'\x08',  # ( 8): (signed) byte forthcoming
 'SX_NETINT':        b'\x09',  # ( 9): Integer in network order forthcoming
 'SX_SCALAR':        b'\x0a',  # (10): Scalar (binary, small) follows (length, data)
 'SX_TIED_ARRAY':    b'\x0b',  # (11): Tied array forthcoming
 'SX_TIED_HASH':     b'\x0c',  # (12): Tied hash forthcoming
 'SX_TIED_SCALAR':   b'\x0d',  # (13): Tied scalar forthcoming
 'SX_SV_UNDEF':      b'\x0e',  # (14): Perl's immortal PL_sv_undef
 'SX_BLESS':         b'\x11',  # (17): Object is blessed
 'SX_IX_BLESS':      b'\x12',  # (18): Object is blessed, classname given by index
 'SX_HOOK':          b'\x13',  # (19): Stored via hook, user-defined
 'SX_OVERLOAD':      b'\x14',  # (20): Overloaded reference
 'SX_TIED_KEY':      b'\x15',  # (21): Tied magic key forthcoming
 'SX_TIED_IDX':      b'\x16',  # (22): Tied magic index forthcoming
 'SX_UTF8STR':       b'\x17',  # (23): UTF-8 string forthcoming (small)
 'SX_LUTF8STR':      b'\x18',  # (24): UTF-8 string forthcoming (large)
 'SX_FLAG_HASH':     b'\x19',  # (25): Hash with flags forthcoming (size, flags, key/flags/value triplet list)
}
