from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import db
from ..util import json_objects, json_records, json


async def test(request):
    return text("test error, not allowed", status=401)

async def searchRootsWithOneParam(request,param1,param2):
    if param1 in ("site_code","collection_code","site_name","collection_name","patient_id_prefix","body_part","access_type","baseline_date","date_shift"):
        query = """\
            select
            b.*,
            c.*,
            a.patient_id_prefix,
            a.body_part,
            a.access_type,
            a.baseline_date,
            a.date_shift
            from
            	submissions a
            	natural join collection_codes b
            	natural join site_codes c
            where  {} like $1
        """.format(param1)
        return json_records(
            await db.fetch(query,[param2])
        )
    else:
        return []

async def searchRootsWithTwoParams(request,param1,param2,param3,param4):
    if param1 in ("site_code","collection_code","site_name","collection_name","patient_id_prefix","body_part","access_type","baseline_date","date_shift") and param3 in  ("site_code","collection_code","site_name","collection_name","patient_id_prefix","body_part","access_type","baseline_date","date_shift"):
            query = """\
                select
                b.*,
                c.*,
                a.patient_id_prefix,
                a.body_part,
                a.access_type,
                a.baseline_date,
                a.date_shift
                from
                	submissions a
                	natural join collection_codes b
                	natural join site_codes c
                where  {} like $1
                and {} like $2
            """.format(param1,param3)
            return json_records(
                await db.fetch(query,[param2,param4])
            )
    else:
        return []

async def searchAll(request):
    query = """\
        select
        b.*,
        c.*,
        a.patient_id_prefix,
        a.body_part,
        a.access_type,
        a.baseline_date,
        a.date_shift
        from
        	submissions a
        	natural join collection_codes b
        	natural join site_codes c
    """
    return json_records(
        await db.fetch(query)
    )
