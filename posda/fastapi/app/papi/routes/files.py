from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database

from ..util import asynctar, asynczip

import os
from io import BytesIO
import aiofiles
import logging
import tempfile


@router.get("/")
async def get_all_files():
    raise HTTPException(detail="listing all files is not allowed", status_code=401)

@router.get("/{file_id}")
async def get_single_file(file_id: int, db: Database = Depends()):
    query = """
        select *
        from file
        where file_id = $1
    """

    return await db.fetch_one(query, [file_id])

@router.get("/series/{series_instance_uid}")
async def get_series_files(series_instance_uid: str, db: Database = Depends()):
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
    records = [x[0] for x in await db.fetch(query, [series_instance_uid])]

    file_name = f"{series_instance_uid}.zip"
    return await asynczip.stream_files(records, file_name)

@router.get("/iec/{iec}")
async def get_iec_files(iec: int, db: Database = Depends()):
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
    records = await db.fetch(query, [iec])

    return await asynczip.stream_files([r['file'] for r in records], f"{iec}.zip")

@router.get("/{file_id}/pixels")
async def get_pixel_data(file_id: int, db: Database = Depends()):
    query = """
        select distinct
            root_path || '/' || rel_path as file,
            pixel_data_offset as file_offset,
            pixel_data_length as size,
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
            natural join dicom_file
            natural join file_location
            natural join file_storage_root
            natural join file_equipment

            natural left join file_slope_intercept
            natural left join slope_intercept

            natural left join file_win_lev
            natural left join window_level

        where file_image.file_id = $1
    """

    record = await db.fetch_one(query, [file_id])

    if len(record) == 0:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.debug(f"parameter file_id was: {file_id}")
        raise HTTPException(status_code=404, detail="no records returned")

    logging.debug(record['file'])

    filename = record['file']
    # TODO: This reads the entire pixel data into memory. We should
    # be doing a chunked read, but it wasn't working with starlette's
    # StreamingResponse for some reason.
    async with aiofiles.open(filename, 'rb') as f:
        await f.seek(record['file_offset'])
        data = await f.read()

    return Response(headers={'Q-DICOM-Rows': str(record['pixel_rows']),
                             'Q-DICOM-Cols': str(record['pixel_columns']),
                             'Q-DICOM-Size': str(record['size']),
                             'Q-DICOM-Bits-Stored': str(record['bits_stored']),
                             'Q-DICOM-Bits-Allocated': str(record['bits_allocated']),
                             'Q-DICOM-PixelRep': str(record['pixel_representation']),
                             'Q-DICOM-Slope': str(record['slope']),
                             'Q-DICOM-Intercept': str(record['intercept']),
                             'Q-DICOM-Window-Center': str(record['window_center']),
                             'Q-DICOM-Window-Width': str(record['window_width']),
                             'Q-DICOM-Pixel-Pad': str(record['pixel_pad']),
                             'Q-DICOM-Samples-Per-Pixel': str(record['samples_per_pixel']),
                             'Q-DICOM-PhotoRep': str(record['photometric_interpretation']),
                             'Q-DICOM-Planar-Config': str(record['planar_configuration']),
                             },
                    media_type="application/octet-stream",
                    content=data)

@router.get("/{file_id}/data")
async def get_data(file_id: int, db: Database = Depends()):
    query = """
        select
            root_path || '/' || rel_path as file,
            size
        from file
        natural join file_location
        natural join file_storage_root
        where file_id = $1
    """

    file_rec = await db.fetch_one(query, [file_id])

    filename = file_rec['file']
    if not os.path.exists(filename):
        raise HTTPException(status_code=404, detail="File not found on disk")

    return FileResponse(file_rec['file'])

@router.get("/{file_id}/path")
async def get_path(file_id: int, db: Database = Depends()):
    query = """
        select
            root_path || '/' || rel_path as file_path
        from file
        natural join file_location
        natural join file_storage_root
        where file_id = $1
    """

    return await db.fetch_one(query, [file_id])


@router.get("/{file_id}/details")
async def get_details(file_id: int, db: Database = Depends()):

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


    return await db.fetch_one(query, [file_id])
