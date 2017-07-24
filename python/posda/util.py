
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
