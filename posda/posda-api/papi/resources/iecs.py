from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic.exceptions import NotFound


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records


from .files import get_data

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
    select
        file_id
    from
        image_equivalence_class_input_image
        natural join file_sop_common
    where
        image_equivalence_class_id = $1
    order by
        -- sometimes instance_number is empty string or null
        case instance_number
            when '' then '0'
            when null then '0'
            else instance_number
        end::int
    """

    return json_records(
        {"file_ids": [x[0] for x in await db.fetch(query, [int(iec)])]}
    )

# /v1/iecs/<iec>/projection
async def get_iec_projection(request, iec, **kwargs):
    """Return the bytes for the output image of an IEC

    This is done by looking up the file_id and then calling
    files.get_data
    """
    query = """
        select file_id
        from image_equivalence_class_out_image
        where image_equivalence_class_id = $1
    """

    results = await db.fetch_one(query, [int(iec)])
    file_id = results[0]

    return await get_data(request, int(file_id), **kwargs)
