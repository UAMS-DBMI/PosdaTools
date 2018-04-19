from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic import Blueprint


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records


blueprint = Blueprint('studies')


async def get_all_studies(request):
    return text("listing all studies is not allowed", status=401)

async def get_single_study(request, study_id):
    query = """
        select
            study_date,
            study_time::text,
            count(distinct series_instance_uid) as series_count
        from file_study
        natural join file_series
        where study_instance_uid = $1
        group by
            study_date,
            study_time
    """

    return json_records(
        await db.fetch_one(query, [study_id])
    )


async def get_all_series(request, study_id):
    query = """
        select distinct
            series_instance_uid
        from file_study
        natural join file_series
        where study_instance_uid = $1
    """

    return json_records(
        await db.fetch(query, [study_id])
    )

blueprint.add_route(get_all_studies, '/')
blueprint.add_route(get_single_study, '/<study_id>')
blueprint.add_route(get_all_series, '/<study_id>/series')
