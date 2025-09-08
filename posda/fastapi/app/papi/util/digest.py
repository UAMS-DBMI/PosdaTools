import hashlib

def md5sum_file(filename):
    """Calculate the md5sum of filename, return (size, digest)"""
    bytes_read = 0
    with open(filename, "rb") as f:
        file_hash = hashlib.md5(usedforsecurity=False)
        while chunk := f.read(8192):
            file_hash.update(chunk)
            bytes_read = len(chunk)

    return bytes_read, file_hash.hexdigest()
