"""
asynctar - Build a tar.gz file from a directory, with asyncio

"""

import tarfile
import asyncio
import aiofiles
import os
from io import BytesIO
from starlette.responses import StreamingResponse


async def add_file_to_tar(tar, filename, arcname):
    f = await aiofiles.open(filename, mode='rb')
    test = BytesIO(await f.read())  # TODO this should read in chunks!

    info = tarfile.TarInfo(arcname)
    info.size = test.getbuffer().nbytes

    print(f"Adding {filename} to tar.. it is {info.size} bytes!")

    tar.addfile(info, fileobj=test)

    f.close()


def stream_directory(path, dl_filename):
    if not path.endswith('/'):
        path += '/'
    async def streaming_fn():
        fake_file = BytesIO()

        # mode w|gz means stream as gzip (differs from w:gz)
        tar = tarfile.open(fileobj=fake_file, mode='w|gz', dereference=True)
        await asyncio.sleep(0)

        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:

                full_filename = os.path.join(dirpath, filename)

                # Remove the leading path info from the filename before
                # adding it to the archive, so it extracs nicely
                arcname = full_filename.replace(path, '')
                # fake_file.seek(0)  # reset to buffer start to begin 
                # fake_file.truncate(0)
                await add_file_to_tar(tar, full_filename, arcname)

                # print("added file, buffer is now:")
                # print(fake_file.bytes.getbuffer().nbytes)


                # yield all bytes in the fake_file buffer, if there are any
                # then clear the buffer and reset it to position 0
                if fake_file.tell() > 0: # there is data to write!
                    fake_file.seek(0)  # move to start of buffer to begin reading
                    while True:
                        b = fake_file.read(1024)
                        await asyncio.sleep(0)
                        if len(b) > 0:
                            yield b
                        else:
                            fake_file.truncate(0)
                            fake_file.seek(0)
                            break

                await asyncio.sleep(0)
            await asyncio.sleep(0)

        tar.close()
        # Any remaining data is written when you call tar.close(), so
        # we need to send any remaining bytes now
        if fake_file.tell() > 0: # there is data to write!
            fake_file.seek(0)  # move to start of buffer to begin reading
            while True:
                b = fake_file.read(1024)
                await asyncio.sleep(0)
                if len(b) > 0:
                    yield b
                else:
                    break

    return StreamingResponse(streaming_fn(), media_type="application/gzip",
                             headers={'Content-Disposition': f'attachment; filename="{dl_filename}"'})

# TODO: this should be combined with stream_directory as they are identical!!
def stream_files(filelist, dl_filename):
    async def streaming_fn():
        fake_file = BytesIO()

        # mode w|gz means stream as gzip (differs from w:gz)
        tar = tarfile.open(fileobj=fake_file, mode='w|gz', dereference=True)
        await asyncio.sleep(0)

        for full_filename in filelist:

            arcname = full_filename
            await add_file_to_tar(tar, full_filename, arcname)

            # yield all bytes in the fake_file buffer, if there are any
            # then clear the buffer and reset it to position 0
            if fake_file.tell() > 0: # there is data to write!
                fake_file.seek(0)  # move to start of buffer to begin reading
                while True:
                    b = fake_file.read(1024)
                    await asyncio.sleep(0)
                    if len(b) > 0:
                        yield b
                    else:
                        fake_file.truncate(0)
                        fake_file.seek(0)
                        break

            await asyncio.sleep(0)

        tar.close()
        # Any remaining data is written when you call tar.close(), so
        # we need to send any remaining bytes now
        if fake_file.tell() > 0: # there is data to write!
            fake_file.seek(0)  # move to start of buffer to begin reading
            while True:
                b = fake_file.read(1024)
                await asyncio.sleep(0)
                if len(b) > 0:
                    yield b
                else:
                    break

    return StreamingResponse(streaming_fn(), media_type="application/gzip",
                             headers={'Content-Disposition': f'attachment; filename="{dl_filename}"'})

