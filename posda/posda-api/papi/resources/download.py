from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic import Blueprint

import aiofiles
import mimetypes
import logging

from ..util import asynctar
from ..util import db


blueprint = Blueprint('download', url_prefix='/download')


async def download_file(request, downloadable_file_id, hash):
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

    async with db.pool.acquire() as conn:
        records = await conn.fetch(query, int(downloadable_file_id), hash)

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.info(f"Invalid request: {downloadable_file_id}/{hash} by "
                     "{request.ip}")
        return json({'error': 'no records returned'}, status=404)


    path = record['file']
    mime_type = record['mime_type']

    ext = mimetypes.guess_extension(mime_type)

    async with aiofiles.open(path, 'rb') as f:
        data = await f.read()

    logging.info(f"Serving request: {downloadable_file_id}/{hash} by "
                 "{request.ip}")
    return HTTPResponse(
        status=200,
        content_type=mime_type,
        headers={'Content-Disposition': 
                 f"attachment; "
                 f"filename=\"downloaded_file_{downloadable_file_id}{ext}\""},
        body_bytes=data
    )

async def download_dir(request, downloadable_dir_id, hash):
    query = """
        select
            path
        from downloadable_dir
        where downloadable_dir_id = $1
          and security_hash = $2
    """

    async with db.pool.acquire() as conn:
        records = await conn.fetch(query, int(downloadable_dir_id), hash)

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.info(f"Invalid request: {downloadable_dir_id}/{hash} by {request.ip}")
        return json({'error': 'no records returned'}, status=404)
        # return HTTPResponse(status=404)


    path = record['path']

    logging.info(f"Serving request: {downloadable_dir_id}/{hash} by {request.ip}")

    return asynctar.stream(response, 
                           path, 
                           f"downloaded_dir_{downloadable_dir_id}.tar.gz")

blueprint.add_route(download_file, 
                    '/file/<downloadable_file_id>/<hash>') 
blueprint.add_route(download_dir,
                    '/dir/<downloadable_dir_id>/<hash>')
