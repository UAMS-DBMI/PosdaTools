import hashlib
import sys

def printe(*args, **kwargs):
    """Print to standard error"""
    print(*args, **kwargs, file=sys.stderr)

def md5sum(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def unpack_n(iterable, n):
    iter_len = len(iterable)
    if iter_len >= n:
        return iterable

    ret = []
    for i in range(n):
        if n > iter_len:
            ret.append(None)
        else:
            ret.append(iterable[n])

    return ret
