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


# async def findCollectionNameFromCode(request,cc):
#     query = """\
#      select
#          collection_name
#      from
#          collection_codes
#      where
#          collection_code = $1
#      """
#     return json_records(
#      await db.fetch(query)
#     )


async def findCollectionNameFromCode(request,cc):
   async with db.pool.acquire() as conn:
       record = await conn.fetchrow("""\
           select
            collection_name
           from
            collection_codes
           where
            collection_code = $1
           """,cc)
       return text(record['collection_name'])


async def findSiteNameFromCode(request,sc):
   async with db.pool.acquire() as conn:
       record = await conn.fetchrow("""\
           select
            site_name
           from
            site_codes
           where
            site_code = $1
           """,sc)
       return text(record['site_name'])


async def addNewSubmission(request):
    async with db.pool.acquire() as conn:
        record = await conn.fetch("""\
            select
             site_name
            from
             site_codes
            where
             site_code = $1
            """,request.json.get('input_site_code'))
        if len(record) == 0:
            await conn.execute(" insert into site_codes (site_code, site_name) VALUES ($1, $2)", request.json.get('input_site_code'),  request.json.get('input_site_name'))

        record = await conn.fetch("""\
           select
            collection_name
           from
            collection_codes
           where
            collection_code = $1
           """,request.json.get('input_collection_code'))
        if len(record) == 0:
            await conn.execute(" insert into collection_codes (collection_code, collection_name) VALUES ($1, $2)", request.json.get('input_collection_code'), request.json.get('input_collection_name'))


        ds = 0
        if request.json.get('input_date_shift') != '':
                ds = request.json.get(int('input_date_shift'))

        #after those 2 finish:
        await conn.execute("""\
            insert
                into submissions
                (site_code, collection_code , patient_id_prefix, body_part,access_type, baseline_date, date_shift )
                VALUES
                ($1, $2, $3 , $4, $5, $6, $7)""",
            request.json.get('input_site_code'),
            request.json.get('input_collection_code'),
            request.json.get('input_patient_id_prefix'),
            request.json.get('input_body_part'),
            request.json.get('input_access_type'),
            request.json.get('input_baseline_date '),
            ds
            )
        return  HTTPResponse(status=201)
