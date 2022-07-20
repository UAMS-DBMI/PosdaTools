"""
asynzip - Build a zip file from a directory, with asyncio?

"""

import asyncio
import zipstream
import os
from starlette.responses import StreamingResponse



async def stream_directory(path, dl_filename):
    if not path.endswith('/'):
        path += '/'


    z = zipstream.ZipFile(allowZip64=True)

    for dirpath, dirnames, filenames in os.walk(path):
        for filename in filenames:
            full_filename = os.path.join(dirpath, filename)

            z.write(full_filename)
            await asyncio.sleep(0)

    return StreamingResponse(z, media_type="application/zip",
                             headers={'Content-Disposition': f'attachment; filename="{dl_filename}"'})


async def stream_files(filelist, dl_filename):
    z = zipstream.ZipFile(allowZip64=True)

    for filename in filelist:
        z.write(str(filename))
        await asyncio.sleep(0)

    return StreamingResponse(iter(z), media_type="application/zip",
                             headers={'Content-Disposition': f'attachment; filename="{dl_filename}"'})
