from fastapi import Depends, APIRouter, HTTPException
from starlette.responses import Response
import os
import logging
import aiofiles

from .auth import logged_in_user, User
from ..util import Database

API_URL = os.environ.get("POSDA_API_URL")
router = APIRouter(
    tags=["WADO-RS"],
    dependencies=[logged_in_user],
    responses={
        401:  {"description": "User is not logged in"},
    }
)


@router.get("/")
async def get_all_studies():
    raise HTTPException(detail="missing endpoint", status_code=401)

#/papi/v1/wadors/timepoint/1/studies/s/series/ss/instances/i/frames/1
@router.get("/timepoint/{timepoint_id}/studies/{study}/series/{series}/instances/{sop}/frames/{frame}")
async def get_frames(
    sop: str,
    frame: int,
    # activity_id: int = None,
    timepoint_id: int = None,
    db: Database = Depends(),
):
    query = """
        select
            root_path || '/' || rel_path as file,
            pixel_data_offset as file_offset,
            xfer_syntax
        from
                activity_timepoint_file
                natural join dicom_file
                natural join file_meta
                natural join file_sop_common
                natural join file_location
                natural join file_storage_root
        where
                activity_timepoint_id = $1
                and sop_instance_uid = $2
    """

    record = await db.fetch_one(query, [timepoint_id, sop])

    if len(record) == 0:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.debug(f"parameters {timepoint_id=},{sop=}")
        raise HTTPException(status_code=404, detail="no records returned")


    filename = record['file']
    # TODO: This reads the entire pixel data into memory. We should
    # be doing a chunked read, but it wasn't working with starlette's
    # StreamingResponse for some reason.
    async with aiofiles.open(filename, 'rb') as f:
        await f.seek(record['file_offset'])
        data = await f.read()

    return Response( 
        headers={'transfer-syntax': str(record['xfer_syntax']),},
        media_type="application/octet-stream; transfer-syntax={}".format(record['xfer_syntax']),
        content=data
    )

@router.get("/activity/{activity_id}/studies/{study}/series/{series}/metadata")
@router.get("/timepoint/{timepoint_id}/studies/{study}/series/{series}/metadata")
async def get_metadata(
    study: str,
    series: str,
    activity_id: int = None,
    timepoint_id: int = None,
    db: Database = Depends(),
):

    if timepoint_id is None:
        # TODO set it by looking up the latest tp for the activity
        
        if activity_id is None:
            raise HTTPException()

    query = """
        select distinct
            root_path || '/' || rel_path as file,
            pixel_data_offset as file_offset,
            pixel_data_length as size,
            bits_stored,
            bits_allocated,
            high_bit,
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
            planar_configuration,
            coalesce(number_of_frames, 1) as number_of_frames,
            iop,
            ipp,
            study_instance_uid,
            series_instance_uid,
            sop_instance_uid,
            pixel_spacing,
            file_id

        from
            activity_timepoint_file
            natural join file_series
            natural join file_study
            natural join file_sop_common
            natural join file_image
            natural join image
            natural join image_geometry
            natural join dicom_file
            natural join file_location
            natural join file_storage_root
            natural join file_equipment

            natural left join file_slope_intercept
            natural left join slope_intercept

            natural left join file_win_lev
            natural left join window_level

        where 
            activity_timepoint_id = $1
            and series_instance_uid = $2
        order by file_id desc
    """

    output = [conv(a) for a in await db.fetch(query, [timepoint_id, series])]

    return output


def to_value(v, vr='UK'):
    if isinstance(v, int):
        value = [v]
    else:
        value = v.split("\\")

    if vr == 'US':
        value = [int(i) for i in value]
    if vr == 'DS':
        value = [float(i) for i in value]

    return {
            "Value": value,
            "vr": vr
    }
def conv(record):
    return {
        '00280030': to_value(record['pixel_spacing'], 'DS'),
        '00080018': to_value(record['sop_instance_uid'], 'UI'),
        '0020000E': to_value(record['series_instance_uid'], 'UI'),
        '0020000D': to_value(record['study_instance_uid'], 'UI'),
        '00280010': to_value(record['pixel_rows'], 'US'),
        '00280011': to_value(record['pixel_columns'], 'US'),
        '00280101': to_value(record['bits_stored'], 'US'),
        '00280100': to_value(record['bits_allocated'], 'US'),
        '00280102': to_value(record['high_bit'], 'US'),
        '00280103': to_value(record['pixel_representation'], 'US'),
        '00281053': to_value(record['slope'], 'DS'),
        '00281052': to_value(record['intercept'], 'DS'),
        '00281050': to_value(record['window_center'], 'DS'),
        '00281051': to_value(record['window_width'], 'DS'),
        '00280002': to_value(record['samples_per_pixel'], 'US'),
        '00280004': to_value(record['photometric_interpretation'], 'CS'),
        "00200032": to_value(record['ipp'], 'DS'),
        "00200037": to_value(record['iop'], 'DS'),
    }

