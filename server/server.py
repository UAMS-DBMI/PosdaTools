#!/usr/bin/env python3.6
import logging
from sanic import Sanic
from sanic.response import json, text, HTTPResponse
import aiofiles
import uuid
import asyncio
import uvloop
import datetime

import asyncpg

LOGIN_TIMEOUT = datetime.timedelta(seconds=20*60)

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
    pool = await asyncpg.create_pool(database='N_posda_files', 
                                     user='postgres',
                                     host='tcia-utilities', 
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
                   image_equivalence_class.image_equivalence_class_id) as file_count


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


@app.route("/api/projects/<state>")
async def get_projects(request, state):
    logging.debug(f"State: {state}")
    processing_status, where_clause = {
        'unreviewed': ('ReadyToReview', ""),
        'good':       ('Reviewed', "and review_status='Good'"),
        'bad':        ('Reviewed', "and review_status='Bad'"),
        'ugly':       ('Reviewed', "and review_status='Broken'"),
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
    after = int(request.args.get('offset') or 0)
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

        where processing_status = 'Reviewed'
          and review_status = '{state}'

          {where_text}

        offset $1
        limit 10
    """

    # print(query)

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
            return text("not logged in", status=404)

    try:
        user = sessions[token]
        user.touch()
        request.headers["user"] = user
        return None
    except KeyError:
        logging.debug("Rejecting request because invalid token")
        return text("not logged in", status=404)


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
    logging.basicConfig(level=logging.DEBUG)
    logging.info("Starting up...")


    app.run(host="0.0.0.0", port=8089, debug=True)
