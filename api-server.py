#!/usr/bin/env python3.6

BASE_URL = "/papi"

import sys
import logging
from sanic import Sanic
from sanic import response
from sanic.response import json, text, HTTPResponse
import aiofiles
import mimetypes

import asyncpg

import asynctar

app = Sanic()

pool = None
DEBUG = False


@app.listener("before_server_start")
async def connect_to_db(sanic, loop):
    global pool
    pool = await asyncpg.create_pool(database='posda_files', 
                                     loop=loop)

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
        logging.info(f"Invalid request: {downloadable_file_id}/{hash} by {request.ip}")
        return json({'error': 'no records returned'}, status=404)


    path = record['file']
    mime_type = record['mime_type']

    ext = mimetypes.guess_extension(mime_type)

    async with aiofiles.open(path, 'rb') as f:
        data = await f.read()

    logging.info(f"Serving request: {downloadable_file_id}/{hash} by {request.ip}")
    return HTTPResponse(status=200,
                        content_type=mime_type,
                        headers={'Content-Disposition': f"attachment; filename=\"downloaded_file_{downloadable_file_id}{ext}\""},
                        body_bytes=data)


@app.route(f"{BASE_URL}/test", methods=["GET", "POST"])
def slash_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "headers": request.headers,
                 "query_string": request.query_string})

@app.route("/test")
async def stream_test(request):
    return asynctar.stream(response, "/mnt/main/test_dicom_data")

@app.route(f"{BASE_URL}/dir/<downloadable_dir_id>/<hash>")
async def get_file(request, downloadable_dir_id, hash):
    query = """
        select
            path
        from downloadable_dir
        where downloadable_dir_id = $1
          and security_hash = $2
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, int(downloadable_dir_id), hash)
    await pool.release(conn)

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.info(f"Invalid request: {downloadable_dir_id}/{hash} by {request.ip}")
        return json({'error': 'no records returned'}, status=404)


    path = record['path']

    logging.info(f"Serving request: {downloadable_dir_id}/{hash} by {request.ip}")

    return asynctar.stream(response, 
                           path, 
                           f"downloaded_dir_{downloadable_dir_id}.tar.gz")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].lower() == 'debug':
        DEBUG = True

    if DEBUG:
        logging.basicConfig(level=logging.DEBUG)
    else :
        logging.basicConfig(level=logging.INFO)
    logging.info("Starting up...")

    app.run(host="0.0.0.0", port=8087, debug=DEBUG)
