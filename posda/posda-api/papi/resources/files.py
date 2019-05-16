from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic.exceptions import NotFound


from ..util import asynctar
from ..util import db
from ..util import json_objects, json_records

import os
from io import BytesIO
import tarfile
import asyncio
import aiofiles
import mimetypes
import logging


async def get_all_files(request, **kwargs):
    return text("listing all files is not allowed", status=401)

async def get_single_file(request, file_id, **kwargs):
    query = """
        select *
        from file
        where file_id = $1
    """

    return json_records(
        await db.fetch_one(query, [int(file_id)])
    )

async def tar_files_and_stream(records, file_name):
    async def streaming_fn(response):
        file_path = f"/tmp/{file_name}.tar.gz"
        tar = tarfile.open(file_path, mode='w|gz', dereference=True)
        out = await aiofiles.open(file_path, mode='rb')
        for filename in records:
            arcname = os.path.join(file_name, os.path.basename(filename))
            f = await aiofiles.open(filename, mode='rb')
            test = BytesIO(await f.read())

            info = tarfile.TarInfo(arcname)
            info.size = test.getbuffer().nbytes

            tar.addfile(info, fileobj=test)
            while True:
                chunk = await out.read(1024 * 512)
                if(not chunk):
                    break
                await response.write(chunk)

        tar.close()
        while True:
            chunk = await out.read(1024 * 512)
            if(not chunk):
                break
            await response.write(chunk)

        f.close()
        out.close()
        os.remove(file_path)

    return response.stream(streaming_fn,
                           content_type='application/gzip',
                           headers={'Content-Disposition': f'attachment; filename="{file_name}.tar.gz"'})


async def get_series_files(request, series_uid, **kwargs):
    query = """
	select root_path || '/' || rel_path as file
			    from
				file_series
				natural join ctp_file
				natural join file_location
				natural join file_storage_root
			    where series_instance_uid = $1
			      and visibility is null
    """
    # use asynctar here to get all the files and return them
    records = [x[0] for x in await db.fetch(query, [series_uid])]

    """
    file_name = f"{series_uid}.tar.gz"
    return asynctar.stream_files(response, records, file_name)
    """
    return await tar_files_and_stream(records, series_uid)

async def get_iec_files(request, iec_id, **kwargs):
    query = """
	select root_path || '/' || rel_path as file
			    from
				ctp_file
				natural join file_location
				natural join file_storage_root
                natural join image_equivalence_class_input_image
			    where image_equivalence_class_id = $1
			      and visibility is null
    """
    # use asynctar here to get all the files and return them
    async with db.pool.acquire() as conn:
        records = [x[0] for x in await conn.fetch(query, int(iec_id))]

    return await tar_files_and_stream(records, iec_id)

async def get_pixel_data(request, file_id, **kwargs):
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

    async with db.pool.acquire() as conn:
        records = await conn.fetch(query, int(file_id))

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

async def get_data(request, file_id, **kwargs):
    query = """
        select
            root_path || '/' || rel_path as file,
            size
        from file
        natural join file_location
        natural join file_storage_root
        where file_id = $1
    """

    file_rec = await db.fetch_one(query, [int(file_id)])

    try:
        async with aiofiles.open(file_rec['file'], 'rb') as f:
            data = await f.read()
    except FileNotFoundError:
        raise NotFound("File not found on disk")


    return HTTPResponse(
        status=200,
        content_type='application/octet',
        body_bytes=data
    )

async def get_details(request, file_id, **kwargs):

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
            patient_id,
            study_instance_uid

        from
            file_image
            natural left join image
            natural left join unique_pixel_data
            natural left join pixel_location
            natural left join file_location
            natural left join file_storage_root
            natural left join file_equipment
            natural left join file_sop_common
            natural left join file_series
            natural left join ctp_file
            natural left join file_patient
            natural left join file_study

            natural left join file_slope_intercept
            natural left join slope_intercept

            natural left join file_win_lev
            natural left join window_level

        where file_image.file_id = $1
    """


    return json_records(
        await db.fetch_one(query, [int(file_id)])
    )
