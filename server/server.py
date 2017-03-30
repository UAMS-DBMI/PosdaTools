#!/usr/bin/env python3.6
import logging
from sanic import Sanic
from sanic.response import json, text

import asyncpg

app = Sanic()

pool = None

async def connect_to_db(sanic, loop):
    global pool
    pool = await asyncpg.create_pool(database='posda_files', 
                                     user='postgres',
                                     host='tcia-utilities', 
                                     loop=loop)

@app.route("/api/projects/<state>")
async def get_projects(request, state):
    logging.debug(f"State: {state}")
    processing_status, where_clause = {
        'unreviewed': ('ReadyToReview', ""),
        'good':       ('Reviewed', "and review_status='Good'"),
        'bad':        ('Reviewed', "and review_status='Bad'"),
        'ugly':       ('Reviewed', "and review_status='Ugly'"),
    }[state.lower()]

    query = f"""
/*
  This query gets a list of what Project/Site combos have IECs waiting
  to be reviewed, along with a count for each.

  It is somewhat complex, as it attempts to figure out the project/site
  of a given IEC based on only the first input image. This is much faster
  than the original simpler query.

  This could be improved further by storing the project/site info
  on an IEC level, either in the image_equivalence_class table or in a
  seperate table.
*/
select
  project_name, 
  site_name,
  count(image_equivalence_class_id)
from (
  select 
        image_equivalence_class_id,
        (select project_name from ctp_file
          where ctp_file.file_id =
          (
          select file_id
          from image_equivalence_class_input_image i
          where i.image_equivalence_class_id = iec.image_equivalence_class_id
          limit 1) 
        ) project_name,
        (select site_name from ctp_file
          where ctp_file.file_id =
          (
          select file_id
          from image_equivalence_class_input_image i
          where i.image_equivalence_class_id = iec.image_equivalence_class_id
          limit 1) 
        ) site_name

  from image_equivalence_class iec

  where processing_status = '{processing_status}' 
  {where_clause}
) a
group by project_name, site_name
order by count desc
    """

    conn = await pool.acquire()
    records = await conn.fetch(query)
    await pool.release(conn)

    return json([dict(i.items()) for i in records])


@app.route("/api/set/<state>")
async def get_set(request, state):
    after = int(request.args.get('after') or 0)
    collection = request.args.get('collection')
    site = request.args.get('site')

    logging.debug(f"get_set:state={state},site={site},collection={collection}")

    handler = {
        'unreviewed': get_unreviewed_data,
        'good': get_good_data,
        'bad': get_bad_data,
        'ugly': get_ugly_data,
    }[state.lower()]

    records = await handler(after, collection, site)

    return json([dict(i.items()) for i in records])

async def get_unreviewed_data(after, collection, site):
    # TODO: This is currently ignoring collection and site!
    query = """
    select
            image_equivalence_class_id,
            series_instance_uid,
            equivalence_class_number,
            processing_status,
            review_status,
            projection_type,
            file_id,
            root_path || '/' || rel_path as path

    from image_equivalence_class

    natural join image_equivalence_class_out_image
    natural join file_location
    natural join file_storage_root

    where processing_status = 'ReadyToReview'
    and image_equivalence_class_id > $1

    limit 10
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, after)
    await pool.release(conn)

    return records

async def get_good_data(after, collection, site):
    return await get_reviewed_data('Good', after, collection, site)

async def get_bad_data(after, collection, site):
    return await get_reviewed_data('Bad', after, collection, site)

async def get_ugly_data(after, collection, site):
    return await get_reviewed_data('Broken', after, collection, site)

async def get_reviewed_data(state, after, collection, site):
    # TODO: This is currently ignoring collection and site!

    where_text = ""

    if collection is not None:
        where_text += f"and project_name = '{collection}' "

    if site is not None:
        where_text += f"and site_name = '{site}' "


    if len(where_text) > 0:
        join_text = """
            join image_equivalence_class_input_image II
              on II.image_equivalence_class_id = I.image_equivalence_class_id
            join ctp_file on ctp_file.file_id = II.file_id
        """
    else:
        join_text = ""


    query = f"""
        select distinct
          I.image_equivalence_class_id,
          series_instance_uid,
          equivalence_class_number,
          processing_status,
          review_status,
          projection_type,
          image_equivalence_class_out_image.file_id,
          root_path || '/' || rel_path as path

        from image_equivalence_class I

        natural join image_equivalence_class_out_image
        natural join file_location
        natural join file_storage_root

        {join_text}

        where I.image_equivalence_class_id > $1
          and processing_status = 'Reviewed'
          and review_status = '{state}'

          {where_text}

        limit 10
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, after)
    await pool.release(conn)

    return records

@app.route("/test")
def slash_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "query_string": request.query_string})

@app.route("/save", methods=["POST"])
def save(request):
    return json(request.json)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    app.run(host="0.0.0.0", port=8129, after_start=connect_to_db, debug=True)
