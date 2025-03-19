from fastapi import Depends, APIRouter, HTTPException
from starlette.responses import Response
from pydantic import BaseModel
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


class ValueModel(BaseModel):
    Value: list
    vr: str

    def from_record(vr, v):
        if isinstance(v, int):
            value = [v]
        elif v is None:
            value = []
        else:
            if "\\" in v:
                value = v.split("\\")
            else:
                value = [v]
            

        if vr == 'US':
            value = [int(i) for i in value]
        if vr == 'DS':
            value = [float(i) for i in value]

        return ValueModel(Value=value, vr=vr)

@router.get("/studies/iec:{iec}/series/{series}/instances/{sop}/frames/{frame}")
async def get_frames_for_iec(
    sop: str,
    frame: int,
    iec: int,
    db: Database = Depends(),
):
    """Get the pixel data for the given SOP Instance UID in the given IEC"""

    query = """
        select
            root_path || '/' || rel_path as file,
            pixel_data_offset as file_offset,
            xfer_syntax
        from
                image_equivalence_class_input_image
                natural join dicom_file
                natural join file_meta
                natural join file_sop_common
                natural join file_location
                natural join file_storage_root
        where
                image_equivalence_class_id = $1
                and sop_instance_uid = $2
    """

    record = await db.fetch_one(query, [iec, sop])

    if len(record) == 0:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.debug(f"parameters {iec=},{sop=}")
        raise HTTPException(status_code=404, detail="no records returned")

    return await stream_file(record['file'], record['xfer_syntax'], record['file_offset'])

@router.get("/studies/timepoint:{timepoint_id}/series/{series}/instances/{sop}/frames/{frame}")
@router.get("/studies/activity:{activity_id}/series/{series}/instances/{sop}/frames/{frame}")
async def get_frames(
    sop: str,
    frame: int,
    activity_id: int = None,
    timepoint_id: int = None,
    db: Database = Depends(),
):
    """Get the pixel data for the given SOP Instance UID"""

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

    return await stream_file(record['file'], record['xfer_syntax'], record['file_offset'])

async def stream_file(filename, transfer_syntax, data_offset):
    # TODO: This reads the entire pixel data into memory. We should
    # be doing a chunked read, but it wasn't working with starlette's
    # StreamingResponse for some reason.
    async with aiofiles.open(filename, 'rb') as f:
        await f.seek(data_offset)
        data = await f.read()

    return Response( 
        media_type="application/octet-stream; transfer-syntax={}".format(transfer_syntax),
        content=data
    )

@router.get("/studies/activity:{activity_id}/series/{series}/metadata",
            summary="Get metdata for a series in an activity")
@router.get("/studies/timepoint:{timepoint_id}/series/{series}/metadata",
            summary="Get metdata for a series in an activity timepoint")
async def get_metadata2(
    series: str,
    activity_id: int = None,
    timepoint_id: int = None,
    db: Database = Depends(),
) -> list[dict[str, ValueModel]]:
    """Get metadata for the given series in the given timepoint,
    
    or if an activity is given, for the latest timepoint.

    Note: this returns only a subset of the metadata for the given series. Only
    that which is required by Cornerstone to display the images.
    """

    if timepoint_id is None:
        # TODO set it by looking up the latest tp for the activity
        raise HTTPException("not implemented yet")
        
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

@router.get("/studies/iec:{iec}/series/{series}/metadata")
async def get_iec_metadata(
    iec: int,
    db: Database = Depends(),
) -> list[dict[str, ValueModel]]:
    """Get series metadata for a specific IEC"""

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
			image_equivalence_class_input_image
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
			image_equivalence_class_id = $1
        order by file_id desc
    """

    output = [conv(a) for a in await db.fetch(query, [iec])]

    return output

def conv(record):
    c = ValueModel.from_record

    return {
        '00280030': c('DS', record['pixel_spacing']),
        '00080018': c('UI', record['sop_instance_uid']),
        '0020000E': c('UI', record['series_instance_uid']),
        '0020000D': c('UI', record['study_instance_uid']),
        '00280010': c('US', record['pixel_rows']),
        '00280011': c('US', record['pixel_columns']),
        '00280101': c('US', record['bits_stored']),
        '00280100': c('US', record['bits_allocated']),
        '00280102': c('US', record['high_bit']),
        '00280103': c('US', record['pixel_representation']),
        '00281053': c('DS', record['slope']),
        '00281052': c('DS', record['intercept']),
        '00281050': c('DS', record['window_center']),
        '00281051': c('DS', record['window_width']),
        '00280002': c('US', record['samples_per_pixel']),
        '00280004': c('CS', record['photometric_interpretation']),
        "00200032": c('DS', record['ipp']),
        "00200037": c('DS', record['iop']),
    }

