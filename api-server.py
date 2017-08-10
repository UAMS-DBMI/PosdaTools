#!/usr/bin/env python3.6

BASE_URL = "/papi"

import sys
import logging
from sanic import Sanic
from sanic.response import json, text, HTTPResponse
import aiofiles
import uuid
import asyncio
import uvloop
import datetime
import mimetypes

import asyncpg

app = Sanic()

pool = None
DEBUG = False


@app.listener("before_server_start")
async def connect_to_db(sanic, loop):
    global pool
    pool = await asyncpg.create_pool(database='posda_files', 
                                     loop=loop)

@app.route(f"{BASE_URL}/details/<file_id>")
async def get_image(request, file_id):

    query = """
        select distinct
            root_path || '/' || rel_path as file, 
            file_offset, 
            size, 
            bits_stored, 
            bits_allocated, 
            pixel_representation, 
            pixel_columns, 
            pixel_rows, 
            photometric_interpretation,

            slope,
            intercept,

            window_width,
            window_center,
            pixel_pad,
            samples_per_pixel,
            planar_configuration

        from
            file_image
            natural join image 
            natural join unique_pixel_data 
            natural join pixel_location
            natural join file_location 
            natural join file_storage_root
            natural join file_equipment

            natural left join file_slope_intercept
            natural left join slope_intercept

            natural left join file_win_lev
            natural left join window_level

        where file_image.file_id = $1
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, int(file_id))
    await pool.release(conn)

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.debug(f"parameter file_id was: {file_id}")
        return json({'error': 'no records returned'}, status=404)

    logging.debug(record['file'])


    path = record['file']
    async with aiofiles.open(path, 'rb') as f:
        await f.seek(record['file_offset'])
        data = await f.read()

    return HTTPResponse(status=200,
                        headers={'Q-DICOM-Rows': record['pixel_rows'],
                                 'Q-DICOM-Cols': record['pixel_columns'],
                                 'Q-DICOM-Size': record['size'],
                                 'Q-DICOM-Bits-Stored': record['bits_stored'],
                                 'Q-DICOM-Bits-Allocated': record['bits_allocated'],
                                 'Q-DICOM-PixelRep': record['pixel_representation'],
                                 'Q-DICOM-Slope': record['slope'],
                                 'Q-DICOM-Intercept': record['intercept'],
                                 'Q-DICOM-Window-Center': record['window_center'],
                                 'Q-DICOM-Window-Width': record['window_width'],
                                 'Q-DICOM-Pixel-Pad': record['pixel_pad'],
                                 'Q-DICOM-Samples-Per-Pixel': record['samples_per_pixel'],
                                 'Q-DICOM-PhotoRep': record['photometric_interpretation'],
                                 'Q-DICOM-Planar-Config': record['planar_configuration'],
                                 },
                        content_type="application/octet-stream",
                        body_bytes=data)

@app.route(f"{BASE_URL}/file/<downloadable_file_id>/<hash>")
async def get_file(request, downloadable_file_id, hash):
    # check that we are within the date

    # get the file
    # write the file

    # TODO: add date check!
    query = """
        select
            root_path || '/' || rel_path as file, 
            size,
            mime_type
        from downloadable_file
        natural join file
        natural join file_location 
        natural join file_storage_root
        where downloadable_file_id = $1
          and security_hash = $2
          and (valid_until is null or now() < valid_until)
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, int(downloadable_file_id), hash)
    await pool.release(conn)

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        return json({'error': 'no records returned'}, status=404)


    path = record['file']
    mime_type = record['mime_type']
    # # -b is "brief, do not output filenames"
    # # -i is "output mime data, rather than human readable"
    # create = asyncio.create_subprocess_exec("file", '-bi', path, stdout=asyncio.subprocess.PIPE)
    # proc = await create
    # logging.debug("process created, about to wait on it")

    # logging.debug("process ended, getting data")
    # mime = (await proc.stdout.read()).decode('ascii') # read entire output
    # logging.debug(f"got data: {mime}")

    ext = mimetypes.guess_extension(mime_type)

    async with aiofiles.open(path, 'rb') as f:
        data = await f.read()

    return HTTPResponse(status=200,
                        content_type=mime_type,
                        headers={'Content-Disposition': f"attachment; filename=\"downloaded_file_{downloadable_file_id}{ext}\""},
                        body_bytes=data)
    # return json({
    #     'get_file_id': get_file_id,
    #     'hash': hash,
    #     'test': record,
    # })

@app.route(f"{BASE_URL}/test", methods=["GET", "POST"])
def slash_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "headers": request.headers,
                 "query_string": request.query_string})


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].lower() == 'debug':
        DEBUG = True

    if DEBUG:
        logging.basicConfig(level=logging.DEBUG)
    else :
        logging.basicConfig(level=logging.ERROR)
    logging.info("Starting up...")

    app.run(host="0.0.0.0", port=8087, debug=DEBUG)
