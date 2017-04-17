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



@app.listener("before_server_start")
async def connect_to_db(sanic, loop):
    global pool
    pool = await asyncpg.create_pool(database='N_posda_files', 
                                     user='postgres',
                                     host='tcia-utilities', 
                                     loop=loop)
    # loop.create_task(user_watch())

@app.route("/vapi/series_info/<series>")
async def get_series_info(request, series):

    query = """
        select file_id 
        from 
            file_series 
            natural join file_sop_common
        where series_instance_uid = $1
        order by
            instance_number::int
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, series)
    await pool.release(conn)

    return json({"file_ids": [i[0] for i in records]})

@app.route("/vapi/details/<file_id>")
async def get_image(request, file_id):

    query = """
        select distinct
            root_path || '/' || rel_path as file, 
            file_offset, 
            size, 
            bits_stored, 
            bits_allocated, 
            pixel_representation, 
            pixel_columns, 
            pixel_rows, 
            photometric_interpretation,

            slope,
            intercept,

            window_width,
            window_center,
            pixel_pad

        from
            file_image
            natural join image 
            natural join unique_pixel_data 
            natural join pixel_location
            natural join file_location 
            natural join file_storage_root
            natural join file_equipment

            natural left join file_slope_intercept
            natural left join slope_intercept

            natural left join file_win_lev
            natural left join window_level

        where file_image.file_id = $1
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, int(file_id))
    await pool.release(conn)

    record = records[0]
    print(record['file'])

# <Record file='/mnt/public-nfs/posda/storage/b0/9c/db/b09cdb23153374e5b088ddc443f02e3a' file_o
# ffset=6620 size=32768 bits_stored=16 bits_allocated=16 pixel_representation=1 pixel_columns=1
# 28 pixel_rows=128 photometric_interpretation='MONOCHROME2' slope='0.00810581' intercept='0' w
# indow_width=None window_center=None pixel_pad=None>


    path = record['file']
    async with aiofiles.open(path, 'rb') as f:
        await f.seek(record['file_offset'])
        data = await f.read()

    return HTTPResponse(status=200,
                        headers={'Q-DICOM-Rows': record['pixel_rows'],
                                 'Q-DICOM-Cols': record['pixel_columns'],
                                 'Q-DICOM-Size': record['size'],
                                 'Q-DICOM-Bits-Stored': record['bits_stored'],
                                 'Q-DICOM-Bits-Allocated': record['bits_allocated'],
                                 'Q-DICOM-PixelRep': record['pixel_representation'],
                                 'Q-DICOM-Slope': record['slope'],
                                 'Q-DICOM-Intercept': record['intercept'],
                                 'Q-DICOM-Window-Center': record['window_center'],
                                 'Q-DICOM-Window-Width': record['window_width'],
                                 'Q-DICOM-Pixel-Pad': record['pixel_pad'],
                                 },
                        content_type="application/octet-stream",
                        body_bytes=data)


@app.route("/vapi/none/<iec>")
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



@app.route("/test", methods=["GET", "POST"])
def slash_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "headers": request.headers,
                 "query_string": request.query_string})


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    logging.info("Starting up...")

    app.run(host="0.0.0.0", port=8089, debug=True)
