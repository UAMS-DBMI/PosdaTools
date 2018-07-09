#!/usr/bin/env python3.6
import sys
import os
import logging
from sanic import Sanic
from sanic.response import json, text, HTTPResponse
import aiofiles
import uuid
import asyncio
import uvloop
import datetime
from urllib.parse import unquote

import asyncpg

DEBUG=False

LOGIN_TIMEOUT = datetime.timedelta(seconds=2*60*60) # 2 hours

sessions = {} # token => username

app = Sanic()

pool = None
eventloop = None

class User(object):
    def __init__(self, name):
        self.name = name
        self.token = uuid.uuid4().hex
        self.touch()

    def age(self):
        return datetime.datetime.now() - self.last_updated

    def is_elderly(self):
        pass

    def touch(self):
        self.last_updated = datetime.datetime.now()

    def __str__(self):
        return f"<User: {self.name}, {self.age()}, {self.token}>"

    def __unicode__(self):
        return self.str()


@app.listener("before_server_start")
async def connect_to_db(sanic, loop):
    global pool
    pool = await asyncpg.create_pool(database='posda_files',
                                     loop=loop)
    loop.create_task(user_watch())

@app.route("/api/details/<iec>")
async def get_details(request, iec):
    query = """
    select
            image_equivalence_class_id,
            series_instance_uid,
            equivalence_class_number,
            processing_status,
            review_status,
            projection_type,
            file_id,
            root_path || '/' || rel_path as path,
            update_user,
            to_char(update_date, 'YYYY-MM-DD HH:MI:SS AM') as update_date,
            (select count(file_id)
             from image_equivalence_class_input_image i
             where i.image_equivalence_class_id =
                   image_equivalence_class.image_equivalence_class_id) as file_count,
            (select body_part_examined
             from file_series
             where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as body_part_examined,
             (select patient_id
              from file_patient
              natural join file_series
              where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as patient_id


    from image_equivalence_class

    natural join image_equivalence_class_out_image
    natural join file_location
    natural join file_storage_root

    where image_equivalence_class_id = $1
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, int(iec))
    await pool.release(conn)

    return json(dict(records[0]))

@app.route("/api/hide/collection/<collection>/<site>")
async def hide_collection(request, collection, site):
    collection = unquote(collection)
    site = unquote(site)

    # TODO: record this action in an audit log! that's why we got username
    user = request.headers['user'] # was injected by login middleware
    logging.debug(f"Hiding: {collection}|{site}")

    query = f"""
        insert into log_iec_hide (user_name, project, site, hidden)
        values ('{user.name}', '{collection}', '{site}', true);

        update image_equivalence_class
        set hidden = true
        where image_equivalence_class_id in (
            select image_equivalence_class_id
            from image_equivalence_class
            natural join image_equivalence_class_input_image
            natural join ctp_file
            where project_name = '{collection}'
              and site_name = '{site}'
        )
    """
    conn = await pool.acquire()
    records = await conn.execute(query)
    logging.debug(f"Updated {records} rows?")
    await pool.release(conn)

    return json({'status': 'success'})

@app.route("/api/unhide/collection/<collection>/<site>")
async def unhide_collection(request, collection, site):
    collection = unquote(collection)
    site = unquote(site)
    # TODO: record this action in an audit log! that's why we got username
    user = request.headers['user'] # was injected by login middleware
    logging.debug(f"Unhiding: {collection}|{site}")

    query = f"""
        insert into log_iec_hide (user_name, project, site, hidden)
        values ('{user.name}', '{collection}', '{site}', false);

        update image_equivalence_class
        set hidden = false
        where image_equivalence_class_id in (
            select image_equivalence_class_id
            from image_equivalence_class
            natural join image_equivalence_class_input_image
            natural join ctp_file
            where project_name = '{collection}'
              and site_name = '{site}'
        )
    """
    conn = await pool.acquire()
    records = await conn.execute(query)
    logging.debug(f"Updated {records} rows?")
    await pool.release(conn)

    return json({'status': 'success'})

@app.route("/api/hide/patient/<collection>/<site>/<patient>")
async def hide_patient(request, collection, site, patient):
    collection = unquote(collection)
    site = unquote(site)
    patient = unquote(patient)

    user = request.headers['user'] # was injected by login middleware
    logging.debug(f"Hiding: {collection}|{site}[{patient}]")

    query = f"""
        insert into log_iec_hide (user_name, project, site, patient, hidden)
        values ('{user.name}', '{collection}', '{site}', '{patient}', true);

        update image_equivalence_class
        set hidden = true
        where image_equivalence_class_id in (
            select image_equivalence_class_id
            from image_equivalence_class
            natural join image_equivalence_class_input_image
            natural join ctp_file
            natural join file_patient
            where project_name = '{collection}'
              and site_name = '{site}'
              and patient_id = '{patient}'
        )
    """
    conn = await pool.acquire()
    records = await conn.execute(query)
    logging.debug(f"Updated {records} rows?")
    await pool.release(conn)

    return json({'status': 'success'})


@app.route("/api/unhide/patient/<collection>/<site>/<patient>")
async def unhide_patient(request, collection, site, patient):
    collection = unquote(collection)
    site = unquote(site)
    patient = unquote(patient)

    user = request.headers['user'] # was injected by login middleware
    logging.debug(f"Hiding: {collection}|{site}[{patient}]")

    query = f"""
        insert into log_iec_hide (user_name, project, site, patient, hidden)
        values ('{user.name}', '{collection}', '{site}', '{patient}', false);

        update image_equivalence_class
        set hidden = false
        where image_equivalence_class_id in (
            select image_equivalence_class_id
            from image_equivalence_class
            natural join image_equivalence_class_input_image
            natural join ctp_file
            natural join file_patient
            where project_name = '{collection}'
              and site_name = '{site}'
              and patient_id = '{patient}'
        )
    """
    conn = await pool.acquire()
    records = await conn.execute(query)
    logging.debug(f"Updated {records} rows?")
    await pool.release(conn)

    return json({'status': 'success'})

@app.route("/api/patients/<collection>/<site>/<state>")
async def get_patients(request, collection, site, state):

    collection = unquote(collection)
    site = unquote(site)

    logging.debug(f"State: {state} {collection}|{site}")
    where_clause = {
        'hidden':       ("hidden"),
        'unhidden':       ("not hidden"),
    }[state.lower()]

    query = f"""
        select distinct patient_id
        from ctp_file
        natural join file_patient
        natural join image_equivalence_class
        natural join image_equivalence_class_input_image
        where {where_clause}
          and project_name = $1
          and site_name = $2
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, collection, site)
    await pool.release(conn)

    return json([i[0] for i in records])


@app.route("/api/projects/<state>")
async def get_projects(request, state):
    logging.debug(f"State: {state}")
    where_clause = {
        'unreviewed': "not hidden and processing_status = 'ReadyToReview'",
        'good':       ("not hidden "
                       "and processing_status = 'Reviewed' "
                       "and review_status='Good'"),

        'bad':       ("not hidden "
                       "and processing_status = 'Reviewed' "
                       "and review_status='Bad'"),

        'blank':       ("not hidden "
                       "and processing_status = 'Reviewed' "
                       "and review_status='Blank'"),

        'scout':       ("not hidden "
                       "and processing_status = 'Reviewed' "
                       "and review_status='Scout'"),

        'other':       ("not hidden "
                       "and processing_status = 'Reviewed' "
                       "and review_status='Other'"),

        'hidden':       ("hidden"),
        'unhidden':       ("not hidden"),

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
          limit 1) limit 1
        ) project_name,
        (select site_name from ctp_file
          where ctp_file.file_id =
          (
          select file_id
          from image_equivalence_class_input_image i
          where i.image_equivalence_class_id = iec.image_equivalence_class_id
          limit 1) limit 1
        ) site_name

  from image_equivalence_class iec

  where {where_clause}
) a
group by project_name, site_name
order by count desc
    """

    conn = await pool.acquire()
    records = await conn.fetch(query)
    await pool.release(conn)

    return json([dict(i.items()) for i in records])

@app.route("/api/get_custom")
async def get_custom_by_params(request):
    after = int(request.args.get('offset') or 0)
    processing_status = request.args.get('processing_status')
    review_status = request.args.get('review_status')
    dicom_file_type = request.args.get('dicom_file_type')
    visual_review_instance_id = request.get('visual_review_instance_id')

    logging.debug(f"get_custom")

    where_text = ""
    if processing_status is not None:
        where_text += f"and processing_status = '{processing_status}' "

    if review_status is not None:
        where_text += f"and review_status = '{review_status}' "

    if dicom_file_type is not None:
        where_text += f"and dicom_file_type = '{dicom_file_type}' "

    if visual_review_instance_id is not None:
        where_text += f"and visual_review_instance_id = {visual_review_instance_id}"

    query = f"""
select distinct image_equivalence_class_id, series_instance_uid, processing_status,
review_status, visibility, count(distinct file_id) as num_files

from image_equivalence_class
    natural join image_equivalence_class_input_image
    natural join dicom_file
    natural join ctp_file

where 1 = 1
    {where_text}
group by image_equivalence_class_id, series_instance_uid, processing_status, review_status, visibility
        """

    logging.debug("get_custom query: " + query)

    conn = await pool.acquire()
    records = await conn.fetch(query)
    await pool.release(conn)

    return json([dict(i.items()) for i in records])

@app.route("/api/set/<state>")
async def get_set(request, state):
    after = int(request.args.get('offset') or 0)
    collection = request.args.get('project')
    site = request.args.get('site')


    logging.debug(f"get_set:state={state},site={site},collection={collection}")

    handler = {
        'unreviewed': get_unreviewed_data,
        'good': get_good_data,
        'bad': get_bad_data,
        'blank': get_blank_data,
        'scout': get_scout_data,
        'other': get_other_data,
    }[state.lower()]

    logging.debug(f"handler chosen: {handler}")

    records = await handler(after, collection, site)
    logging.debug("get_set:request handled, emitting response now")

    return json([dict(i.items()) for i in records])

async def get_unreviewed_data(after, collection, site):
    where_text = ""

    if collection is not None:
        where_text += f"and project_name = '{collection}' "

    if site is not None:
        where_text += f"and site_name = '{site}' "

    query = f"""
select
  image_equivalence_class_id,
  series_instance_uid,
  equivalence_class_number,
  processing_status,
  review_status,
  projection_type,
  image_equivalence_class_out_image.file_id,
  root_path || '/' || rel_path as path,
            (select count(file_id)
             from image_equivalence_class_input_image i
             where i.image_equivalence_class_id =
                   image_equivalence_class.image_equivalence_class_id) as file_count,
            (select body_part_examined
             from file_series
             where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as body_part_examined,
             (select patient_id
              from file_patient
              natural join file_series
              where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as patient_id
from (
  /*
    Acquire the project_name and site_name associated with each IEC
    by looking only at the first file_id of it's input image set.
    This is pretty ugly, but is more than 100x faster than other
    solutions.

    It could probably be sped up even more by storing project/site name
    at the IEC level (say, in image_equivalence_class table)
    Quasar, 2017-04-27
  */
  select
    image_equivalence_class_id,
    (select project_name from ctp_file
      where ctp_file.file_id =
      (
      select file_id
      from image_equivalence_class_input_image i
      where i.image_equivalence_class_id = iec.image_equivalence_class_id
      limit 1) limit 1
    ) project_name,
    (select site_name from ctp_file
      where ctp_file.file_id =
      (
      select file_id
      from image_equivalence_class_input_image i
      where i.image_equivalence_class_id = iec.image_equivalence_class_id
      limit 1) limit 1
    ) site_name,
    processing_status

  from image_equivalence_class iec

  where not hidden
    and processing_status = 'ReadyToReview'
  order by image_equivalence_class_id
) iecs
natural join image_equivalence_class
natural join image_equivalence_class_out_image
natural join file_location
natural join file_storage_root

where 1 = 1
  and image_equivalence_class_id > $1
{where_text}

limit 1
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, after)
    await pool.release(conn)

    return records

async def get_good_data(after, collection, site):
    return await get_reviewed_data('Good', after, collection, site)

async def get_bad_data(after, collection, site):
    return await get_reviewed_data('Bad', after, collection, site)

async def get_blank_data(after, collection, site):
    return await get_reviewed_data('Blank', after, collection, site)
async def get_scout_data(after, collection, site):
    return await get_reviewed_data('Scout', after, collection, site)
async def get_other_data(after, collection, site):
    return await get_reviewed_data('Other', after, collection, site)

async def get_reviewed_data(state, after, collection, site):
    where_text = ""

    if collection is not None:
        where_text += f"and project_name = '{collection}' "

    if site is not None:
        where_text += f"and site_name = '{site}' "

    query = f"""
select
  image_equivalence_class_id,
  series_instance_uid,
  equivalence_class_number,
  processing_status,
  review_status,
  projection_type,
  image_equivalence_class_out_image.file_id,
  root_path || '/' || rel_path as path,
            (select count(file_id)
             from image_equivalence_class_input_image i
             where i.image_equivalence_class_id =
                   image_equivalence_class.image_equivalence_class_id) as file_count,
            (select body_part_examined
             from file_series
             where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as body_part_examined,
             (select patient_id
              from file_patient
              natural join file_series
              where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as patient_id
from (
  /*
    Acquire the project_name and site_name associated with each IEC
    by looking only at the first file_id of it's input image set.
    This is pretty ugly, but is more than 100x faster than other
    solutions.

    It could probably be sped up even more by storing project/site name
    at the IEC level (say, in image_equivalence_class table)
    Quasar, 2017-04-27
  */
  select
    image_equivalence_class_id,
    (select project_name from ctp_file
      where ctp_file.file_id =
      (
      select file_id
      from image_equivalence_class_input_image i
      where i.image_equivalence_class_id = iec.image_equivalence_class_id
      limit 1) limit 1
    ) project_name,
    (select site_name from ctp_file
      where ctp_file.file_id =
      (
      select file_id
      from image_equivalence_class_input_image i
      where i.image_equivalence_class_id = iec.image_equivalence_class_id
      limit 1) limit 1
    ) site_name,
    processing_status

  from image_equivalence_class iec

  where not hidden
    and processing_status = 'Reviewed'
    and review_status = '{state}'
  order by image_equivalence_class_id
) iecs
natural join image_equivalence_class
natural join image_equivalence_class_out_image
natural join file_location
natural join file_storage_root

where 1 = 1
  and image_equivalence_class_id > $1
{where_text}

limit 1
    """

    # print(query)
    logging.debug(query)

    conn = await pool.acquire()
    records = await conn.fetch(query, after)
    await pool.release(conn)

    return records

@app.route("/api/img")
async def image_from_id(request):
    path = request.args['path'][0]
    async with aiofiles.open(path, 'rb') as f:
        data = await f.read()

    return HTTPResponse(status=200,
                        headers=None,
                        content_type="image/jpeg",
                        body_bytes=data)


@app.route("/api/new_token/<user>")
async def new_token(request, user):
    user_obj = User(user)
    sessions[user_obj.token] = user_obj
    logging.debug(f"Creating new session for {user_obj.name}: {user_obj.token}")

    return json({'token': user_obj.token})


@app.route("/test", methods=["GET", "POST"])
def slash_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "headers": request.headers,
                 "query_string": request.query_string})

@app.middleware('request')
async def login_check(request):
    if DEBUG:
        request.headers["user"] = User('quasarj')
        return None
    logging.debug(f"### {request.url}?{request.query_string}")
    if 'new_token' in request.url:
        return None

    # get token from args, or from json body
    token = request.args.get('token', None)
    if token is not None:
        # print("Token from get: ", token)
        pass
    else:
        # try to find it in the request body
        try:
            details = request.json
            token = details['token']
            # logging.debug("Token from json: ", token)
        except Exception as e:
            logging.debug("Rejecting request because no token")
            return text("not logged in", status=401)

    try:
        user = sessions[token]
        user.touch()
        request.headers["user"] = user
        return None
    except KeyError:
        logging.debug("Rejecting request because invalid token")
        return text("not logged in", status=401)


@app.route("/api/save", methods=["POST"])
async def save(request):
    user = request.headers['user'] # was injected by login middleware
    details = request.json
    iec = details['iec']
    state = details['state'].title()

    logging.debug(f"Setting {iec} to {state}, by {user.name}")

    # TODO: There is a problem with conn.execute() and bind vars
    #       in version 0.5.1 of asyncpg, which we are currently
    #       pinned to because of using old postgres 8!
    query = f"""
        update image_equivalence_class
        set processing_status = 'Reviewed',
            review_status = '{state}',
            update_user = '{user.name}',
            update_date = now()
        where image_equivalence_class_id = {iec}
    """
    conn = await pool.acquire()
    records = await conn.execute(query)
    logging.debug(f"Updated {records} rows?")
    await pool.release(conn)

    return json({'status': 'success'})

async def user_watch():
    await asyncio.sleep(10)
    # logging.debug("Checking logins...")

    to_delete = []
    for t in sessions:
        user = sessions[t]
        if user.age() > LOGIN_TIMEOUT:
            logging.debug(f"Dropping login session for user: {user.name}")
            to_delete.append(t)

    for t in to_delete:
        del sessions[t]

    # put ourselves back on the queue
    asyncio.get_event_loop().create_task(user_watch())

if __name__ == "__main__":
    if os.environ.get('DEBUG', 0) != 0:
        DEBUG = True

    if len(sys.argv) > 1 and sys.argv[1].lower() == 'debug':
        DEBUG = True

    if DEBUG:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.ERROR)

    logging.info("Starting up...")


    app.run(host="0.0.0.0", port=8089, debug=DEBUG)
