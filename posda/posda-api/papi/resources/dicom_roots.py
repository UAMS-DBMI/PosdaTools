from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import db
from ..util import json_objects, json_records, json


async def test(request):
    return text("test error, not allowed", status=401)

async def searchRoots(request):
    whereclause = "where 1 = 1 "
    values = []
    for i,(key,value) in enumerate(request.query_args):
        if key in ("site_code","collection_code","site_name","collection_name","patient_id_prefix","body_part","access_type","baseline_date","date_shift"):
            whereclause +=  " and {} like ${} ".format(key,i+1)
            values.append(value)
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
            {}
    """.format(whereclause)
    return json_records(
        await db.fetch(query,values)
    )


async def checkCC(request):
    query = """\
        select
            exists(*)
        from
            collection_code
        where
            collection_code = $1
            and collection_name = $2
        """
            return json_records(
                await db.fetch(query,collection_code,collection_name)
            )
