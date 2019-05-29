from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records

from ..auth import login_required
from ..models import Collection


@login_required
async def get_all_collections(request, **kwargs):
    query = """
        select distinct
            project_name as collection,
            site_name as site
        from ctp_file
    """

    arguments = []

    if 'collection' in request.args:
        return await get_collections_by_collection(
            request.args['collection'][0])

    if 'site' in request.args:
        return await get_collections_by_site(
            request.args['site'][0])

    return json_records(
        await db.fetch(query, arguments)
    )

async def get_collections_by_collection(collection_name):
    query = """
        select distinct
            project_name as collection,
            site_name as site
        from ctp_file
        where project_name = $1
    """

    return json_records(
        await db.fetch(query, [collection_name])
    )

async def get_collections_by_site(site_name):
    query = """
        select distinct
            project_name as collection,
            site_name as site
        from ctp_file
        where site_name = $1
    """

    return json_records(
        await db.fetch(query, [site_name])
    )


async def get_single_collection(request, collection_id, site_id, **kwargs):
    query = """
        select 
            project_name as collection,
            site_name as site,
            count(file_id) as file_count,
            count(distinct patient_name) as patient_count
        from ctp_file
        natural join file_patient
        where project_name = $1
          and site_name = $2
        group by 
            project_name, site_name
    """

    return json_records(
        await db.fetch_one(query, [collection_id, site_id])
    )


async def get_all_patients(request, collection_id, site_id, **kwargs):
    query = """
        select distinct 
            patient_name as patient 
        from ctp_file 
        natural join file_patient 
        where project_name = $1
          and site_name = $2
    """

    return json_records(
        await db.fetch(query, [collection_id, site_id])
    )

async def get_single_patient(request, collection_id, site_id, patient_id, **kwargs):
    query = """
        select
            patient_name as patient,
            max(patient_id) as patient_id,
            max(sex) as patient_sex,
            max(ethnic_group) as patient_ethnic_group,
            array_agg(distinct comments) as comments,
            count(file_id) as file_count,
            count(distinct study_instance_uid) as study_count
        from ctp_file 
        natural join file_patient 
        natural join file_study
        where project_name = $1
          and site_name = $2
          and patient_name = $3
        group by patient_name
    """

    return json_records(
        await db.fetch_one(query, [collection_id, site_id, patient_id])
    )

async def get_all_studies(request, collection_id, site_id, patient_id, **kwargs):
    query = """
        select distinct 
            project_name as collection,
            site_name as site,
            patient_name as patient,
            study_instance_uid
        from ctp_file 
        natural join file_patient 
        natural join file_study
        where project_name = $1
          and site_name = $2
          and patient_name = $3
    """

    return json_records(
        await db.fetch(query, [collection_id, site_id, patient_id])
    )
