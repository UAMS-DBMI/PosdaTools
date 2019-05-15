from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic.exceptions import NotFound


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records

import os
from io import BytesIO
import tarfile
import asyncio
import aiofiles
import mimetypes
import logging


async def get_all_iecs(request, **kwargs):
    return text("listing all iecs is not allowed", status=401)

# /v1/iecs/<iec>
async def get_iec_details(request, iec, **kwargs):
    query = """
        select *
        from image_equivalence_class
        where image_equivalence_class_id = $1
    """

    return json_records(
        await db.fetch(query, [int(iec)])
    )

# /v1/iecs/<iec>/files
async def get_iec_files(request, iec, **kwargs):
    query = """
        select file_id
        from image_equivalence_class_input_image
        where image_equivalence_class_id = $1
    """

    return json_records(
        {"file_ids": [x[0] for x in await db.fetch(query, [int(iec)])]}
    )
