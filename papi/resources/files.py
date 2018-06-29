from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic.exceptions import NotFound


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records

import aiofiles
import mimetypes


async def get_all_files(request, **kwargs):
    return text("listing all files is not allowed", status=401)

async def get_single_file(request, file_id, **kwargs):
    query = """
        select *
        from file
        where file_id = $1
    """

    return json_records(
        await db.fetch_one(query, [int(file_id)])
    )

async def get_pixel_data(request, file_id, **kwargs):
    # TODO: make this real
    return text("binary pixel data here")

async def get_data(request, file_id, **kwargs):
    query = """
        select
            root_path || '/' || rel_path as file, 
            size
        from file
        natural join file_location 
        natural join file_storage_root
        where file_id = $1
    """

    file_rec = await db.fetch_one(query, [int(file_id)])

    try:
        async with aiofiles.open(file_rec['file'], 'rb') as f:
            data = await f.read()
    except FileNotFoundError:
        raise NotFound("File not found on disk")


    return HTTPResponse(
        status=200,
        content_type='application/octet',
        body_bytes=data
    )
