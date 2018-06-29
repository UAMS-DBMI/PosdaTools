from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records


async def get_all_series(request, **kwargs):
    return text("listing all series is not allowed", status=401)

async def get_single_series(request, series_id, **kwargs):
    query = """
        select distinct
            series_instance_uid,
            series_date,
            series_time::text,
            modality,
            laterality,
            series_description,
            count(file_id) as file_count
        from file_series
        where series_instance_uid = $1
        group by
            series_instance_uid,
            series_date,
            series_time,
            modality,
            laterality,
            series_description
    """

    return json_records(
        await db.fetch_one(query, [series_id])
    )


async def get_all_files(request, series_id, **kwargs):
    query = """
        select distinct
            file_id
        from file_series
        where series_instance_uid = $1
    """

    return json_records(
        await db.fetch(query, [series_id])
    )
