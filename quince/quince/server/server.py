#!/usr/bin/env python3.6
import sys
import logging
from sanic import Sanic
from sanic.response import json, text, HTTPResponse
import aiofiles
import uuid
import datetime

import asyncpg

LOGIN_TIMEOUT = datetime.timedelta(seconds=20*60)

sessions = {} # token => username

app = Sanic()

pool = None
eventloop = None

DEBUG = False


@app.listener("before_server_start")
async def connect_to_db(sanic, loop):
    global pool
    pool = await asyncpg.create_pool(database='posda_files',
                                     loop=loop)
    # loop.create_task(user_watch())

@app.route("/vapi/extra_details/<file_id:int>")
async def get_series_info(request, file_id):

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
            pixel_pad,

            project_name,
            site_name,
            sop_instance_uid,
            series_instance_uid,
            modality,
            body_part_examined,
            series_description,
            patient_id

        from
            file_image
            natural join image
            natural join unique_pixel_data
            natural join pixel_location
            natural join file_location
            natural join file_storage_root
            natural join file_equipment
            natural join file_sop_common
            natural join file_series
            natural join ctp_file
            natural join file_patient

            natural left join file_slope_intercept
            natural left join slope_intercept

            natural left join file_win_lev
            natural left join window_level

        where file_image.file_id = $1
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, file_id)
    await pool.release(conn)

    return json(dict(records[0]))

@app.route("/vapi/iec_info/<iec:int>")
async def get_iec_info(request, iec):

    query = """
    select
        file_id
    from
        image_equivalence_class_input_image
        natural join file_sop_common
    where
        image_equivalence_class_id = $1
    order by
        -- sometimes instance_number is empty string or null
        case instance_number
            when '' then '0'
            when null then '0'
            else instance_number
        end::int
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, iec)
    await pool.release(conn)

    return json({"file_ids": [i[0] for i in records]})

@app.route("/vapi/series_info/<series>")
async def get_series_info(request, series):

    query = """
        select file_id
        from
            file_series
            natural join file_sop_common
            natural join ctp_file
        where series_instance_uid = $1
          and visibility is null
        order by
            -- sometimes instance_number is empty string or null
            case instance_number
                when '' then '0'
                when null then '0'
                else instance_number
            end::int
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
            pixel_pad,
            samples_per_pixel,
            planar_configuration

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

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.debug(f"parameter file_id was: {file_id}")
        return json({'error': 'no records returned'}, status=404)

    logging.debug(record['file'])


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
                                 'Q-DICOM-Samples-Per-Pixel': record['samples_per_pixel'],
                                 'Q-DICOM-PhotoRep': record['photometric_interpretation'],
                                 'Q-DICOM-Planar-Config': record['planar_configuration'],
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

@app.route("/vapi/details/ROI/<file_id>")
async def get_image(request, file_id):

    query = """
        select
        	a.roi_id
        	,a.roi_name
        	,c.roi_contour_id
            ,i.pixel_rows
	        ,i.pixel_columns
            ,j.ipp
            ,i.pixel_spacing
            ,a.roi_color
        	,c.contour_data
        from
        	roi a
        	--natural join file_roi_image_linkage b --file_id
        	join roi_contour c  --roi_id
        		on a.roi_id = c.roi_id
        	join contour_image d
        		on d.roi_contour_id = c.roi_contour_id
        	join file_sop_common e
        		on e.sop_instance_uid = d.sop_instance
        	join file f
        		on f.file_id = e.file_id
        	join file_series g
        		on g.file_id = f.file_id
            join file_image h
        		on f.file_id = h.file_id
        	join image i
        		on h.image_id = i.image_id
        	join image_geometry j
        		on i.image_id = j.image_id
        	where g.file_id = $1
    """

    conn = await pool.acquire()
    records = await conn.fetch(query, int(file_id))
    await pool.release(conn)

    rois = []
    for row in records:

        ipp_split = row[5].split('\\')
        pxlspc = row[6].split('\\')
        rgb = row[7].split('\\')

        points = row[8].split('\\')
        splitpoints = iter(points)

        rois.append({"roi_id": row[0],
                     "roi_name": row[1],
                     "roi_contour_id": row[2],
                     "pixel_rows": row[3],
                     "pixel_columns": row[4],
                     "ipp": ipp_split,
                     "pixel_spacing": pxlspc,
                     "roi_color": rgb,
                     "contour_data": [(x,y) for x,y,z in zip(splitpoints,splitpoints,splitpoints)]})
    return json(rois)

@app.route("/test", methods=["GET", "POST"])
def slash_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "headers": request.headers,
                 "query_string": request.query_string})


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1].lower() == 'debug':
        DEBUG = True

    if DEBUG:
        logging.basicConfig(level=logging.DEBUG)
    else :
        logging.basicConfig(level=logging.ERROR)
    logging.info("Starting up...")

    app.run(host="0.0.0.0", port=8088, debug=DEBUG)
