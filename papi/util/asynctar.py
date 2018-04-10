"""
asynctar - Build a tar.gz file from a directory, with asyncio

"""

import tarfile
import asyncio
import aiofiles
import os
from io import BytesIO

class ResponseFile:
    def __init__(self, response):
        self._response = response

    def write(self, data):
        self._response.write(data)

    def tell(self):
        return 0

async def add_file_to_tar(tar, filename, arcname):
    f = await aiofiles.open(filename, mode='rb')
    test = BytesIO(await f.read())

    info = tarfile.TarInfo(arcname)
    info.size = test.getbuffer().nbytes

    tar.addfile(info, fileobj=test)


def stream(response, path, dl_filename):
    if not path.endswith('/'):
        path += '/'
    async def streaming_fn(response):
        fake_file = ResponseFile(response)

        # mode w|gz means stream as gzip (differs from w:gz)
        tar = tarfile.open(fileobj=fake_file, mode='w|gz', dereference=True)
        await asyncio.sleep(0)

        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:

                full_filename = os.path.join(dirpath, filename)

                # Remove the leading path info from the filename before
                # adding it to the archive, so it extracs nicely
                arcname = full_filename.replace(path, '')
                await add_file_to_tar(tar, full_filename, arcname)

                await asyncio.sleep(0)
            await asyncio.sleep(0)

        tar.close()

    return response.stream(streaming_fn, 
                           content_type='application/gzip',
                           headers={'Content-Disposition': f'attachment; filename="{dl_filename}"'})
