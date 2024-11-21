from fastapi import Depends, APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List
import datetime
import os

from .auth import logged_in_user, User
from ..util import Database

API_URL = os.environ.get("POSDA_API_URL")
router = APIRouter(
    tags=["Series"],
    dependencies=[logged_in_user],
    responses={
        401:  {"description": "User is not logged in"},
    }
)


@router.get("/")
async def get_all_studies():
    raise HTTPException(detail="listing all series is not allowed", status_code=401)

@router.get("/{series_instance_uid}")
async def get_single_series(series_instance_uid: str, db: Database = Depends(),
        user: User = logged_in_user):
    query = """
        select distinct
            series_instance_uid,
            series_date,
            series_time::text,
            modality,
            laterality,
            series_description,
            count(file_id) as file_count
        from file_series
        where series_instance_uid = $1
        group by
            series_instance_uid,
            series_date,
            series_time,
            modality,
            laterality,
            series_description
    """

    return await db.fetch_one(query, [series_instance_uid])

@router.get("/{series_instance_uid}/ohif")
async def get_ohif_config(series_instance_uid: str, 
                          activity_id: int = None,
                          activity_timepoint_id: int = None,
                          db: Database = Depends()):

    """Get a JSON config for the OHIF viewer

    Follows most of the rules of get_all_files below.

    Minimal output prodcued:

    {
        "studies": [
        {
            "StudyInstanceUID": "1.2.840.113619.2.5.1762583153.215519.978957063.78",
            "series": [
            {
                "SeriesDescription": "Not needed, but keep it",
                "SeriesInstanceUID": "1.2.840.113619.2.5.1762583153.215519.978957063.121",
                "instances": [
                {
                    "metadata": {
                        "Columns": 888,
                        "Rows": 766,
                        "BitsAllocated": 16,
                        "SOPInstanceUID": "1.2.840.113619.2.5.1762583153.215519.978957063.124",
                        "SeriesInstanceUID": "1.2.840.113619.2.5.1762583153.215519.978957063.121",
                        "StudyInstanceUID": "1.2.840.113619.2.5.1762583153.215519.978957063.78"
                    },
                    "url": "dicomweb:http://quasar2.ad.uams.edu/papi/v1/files/195/data"
                }
            ]
            }
        ]
        }
    ]
    }
    """
    query = """
        select
            study_instance_uid,
            series_instance_uid,
            series_description,
            sop_instance_uid,
            file_id,
            pixel_columns,
            pixel_rows,
            bits_allocated,
            instance_number,
            image_type,
            samples_per_pixel,
            photometric_interpretation,
            bits_stored,
            high_bit,
            pixel_representation,
            pixel_spacing,
            iop,
            ipp,
            modality

        from file_series
        natural join file_study
        natural join file_sop_common
        natural join file_image
        natural join image
        natural join file_image_geometry
        natural join image_geometry
        where series_instance_uid = $1

        order by
            case instance_number
                when '' then '0'
                when null then '0'
                else instance_number
            end::int
    """
    results = await db.fetch(query, [series_instance_uid])

    study_instance_uid = results[0]["study_instance_uid"]
    series_description = results[0]["series_description"]

    def dcm_to_list(val):
        return val.split("\\")

    def spacing(row, col):
        if row is None: row = 0.5
        if col is None: col = 0.5
        return [row, col]

    instances = []
    for row in results:
        file_id = row["file_id"]
        metadata = {
            "Columns":              row["pixel_columns"],
            "Rows":                 row["pixel_rows"],
            "InstanceNumber":       row["instance_number"],
            "PhotometricInterpretation":       row["photometric_interpretation"],
            "BitsAllocated":        row["bits_allocated"],
            "BitsStored":           row["bits_stored"],
            "PixelRepresentation":  row["pixel_representation"],
            "SamplesPerPixel":      row["samples_per_pixel"],
            "PixelSpacing":         dcm_to_list(row["pixel_spacing"]),
            "HighBit":              row["high_bit"],
            "ImageOrientationPatient":       dcm_to_list(row["iop"]),
            "ImagePositionPatient": dcm_to_list(row["ipp"]),
            "ImageType":            dcm_to_list(row["image_type"]),
            "Modality":             row["modality"],
            "SOPInstanceUID":       row["sop_instance_uid"],
            "SeriesInstanceUID":    series_instance_uid,
            "StudyInstanceUID":     row["study_instance_uid"],
        }

        instances.append({
            "metadata": metadata,
            "url": f"dicomweb:{API_URL}/v1/files/{file_id}/data"
        })

    output = {
        "studies": [{
            "StudyInstanceUID": study_instance_uid,
            "series": [{
                "SeriesInstanceUID": series_instance_uid,
                "SeriesDescription": series_description,
                "instances": instances
            }]
        }]
    }

    return output


class Frame(BaseModel):
    file_id: int
    frames: int

@router.get("/{series_instance_uid}@{activity_id}/frames",
            summary="Get frames for a series in the given activity")
async def get_frames_activity(series_instance_uid: str,
                              activity_id: int,
                              db: Database = Depends()) -> list[Frame]:
    query = f"""\
        select max(activity_timepoint_id)
        from activity_timepoint
        where activity_id = $1
    """
    
    res = await db.fetch_one(query, [activity_id])

    activity_timepoint_id = res["max"]
    return await get_frames_timepoint(series_instance_uid, activity_timepoint_id, db)


@router.get("/{series_instance_uid}:{activity_timepoint_id}/frames",
            summary="Get frames for a series in the given timepoint")
async def get_frames_timepoint(series_instance_uid: str,
                               activity_timepoint_id: int,
                               db: Database = Depends()) -> list[Frame]:

    query = f"""\
        with timepoint_files as (
            select file_id
            from activity_timepoint_file
            where activity_timepoint_id = $2
        )
        select 
            file_id, 
            coalesce(number_of_frames, 1) as frames

        from
            timepoint_files
            natural join file_series
            natural join file_sop_common
            natural left join file_image
            natural left join image
        where series_instance_uid = $1
        order by
            -- sometimes instance_number is empty string or null
            case instance_number
                when '' then '0'
                when null then '0'
                else instance_number
            end::int
    """

    return [dict(x) for x in await db.fetch(query, [series_instance_uid, activity_timepoint_id])]

@router.get("/{series_instance_uid}/frames",
            summary="Get ALL frames for a series")
async def get_frames_latest(series_instance_uid: str,
                            db: Database = Depends()) -> list[Frame]:
    """Get ALL frames for a series.

    This will include files from any and all activities and timepoints.
    This is seldom what you want.
    """
    query = f"""\
        select 
            file_id, 
            coalesce(number_of_frames, 1) as frames

        from
            file_series
            natural join file_sop_common
            natural left join file_image
            natural left join image
        where series_instance_uid = $1
        order by
            -- sometimes instance_number is empty string or null
            case instance_number
                when '' then '0'
                when null then '0'
                else instance_number
            end::int
    """

    # have to convert to dict for FastAPI's type checking to work
    frames = [dict(x) for x in await db.fetch(query, [series_instance_uid])]
    return frames



@router.get("/{series_instance_uid}/files", 
            summary="Get ALL files for a series")
@router.get("/{series_instance_uid}:{activity_timepoint_id}/files", 
            summary="Get files for a series in the given timepoint")
@router.get("/{series_instance_uid}@{activity_id}/files",
            summary="Get files for a series in the given activity")
async def get_all_files(series_instance_uid: str, 
                        activity_id: int = None,
                        activity_timepoint_id: int = None,
                        db: Database = Depends()):
    """Get a list of all files in the series


    If activity_id and activity_timepoint_id are unset, returns all files 
    in the series that are not hidden.

    If activity_id is set, return all files (hidden or not) from the series
    which are in the latest timepoint in the activity.

    If activity_timepoint_id is set, return all files (hidden or not) from
    the series which are in the given timepoint.

    If both activity_id and activity_timepoint_id are set, 
    activity_timepoint_id takes precedence.
    """

    # return dict(series=series_instance_uid, a=activity_id, tp=activity_timepoint_id)

    if activity_timepoint_id is not None:
        query = f"""
            with timepoint_files as (
                select file_id
                from activity_timepoint_file
                where activity_timepoint_id = {activity_timepoint_id}
            )
            select file_id
            from
                timepoint_files
                natural join file_series
                natural join file_sop_common
            where series_instance_uid = $1
            order by
                -- sometimes instance_number is empty string or null
                case instance_number
                    when '' then '0'
                    when null then '0'
                    else instance_number
                end::int
        """
    elif activity_id is not None:
        query = f"""
            with timepoint_files as (
                select file_id
                from activity_timepoint_file
                where
                    activity_timepoint_id = (
                        select max(activity_timepoint_id)
                        from activity_timepoint
                        where activity_id = {activity_id}
                    )
            )
            select file_id
            from
                timepoint_files
                natural join file_series
                natural join file_sop_common
            where series_instance_uid = $1
            order by
                -- sometimes instance_number is empty string or null
                case instance_number
                    when '' then '0'
                    when null then '0'
                    else instance_number
                end::int
        """
    else:
        query = """
            select file_id
            from
                file_series
                natural left join file_sop_common
                natural left join ctp_file
            where series_instance_uid = $1
            order by
                -- sometimes instance_number is empty string or null
                case instance_number
                    when '' then '0'
                    when null then '0'
                    else instance_number
                end::int
        """

    return {"file_ids": [x[0] for x in await db.fetch(query, [series_instance_uid])]}


class Timepoint(BaseModel):
    activity_id: int
    activity_timepoint_id: int
    creating_user: str
    when_created: datetime.datetime

class ActivityModel(BaseModel):
    activities: list[int]
    timepoints: list[Timepoint]

@router.get("/{series_instance_uid}/activities")
async def get_all_activities(series_instance_uid: str, 
                        db: Database = Depends()) -> ActivityModel:
    """Get a list of all activities and timepoints this series occurs in.
    """

    act_query = """\
        select distinct
                activity_id
        from
            file_series
                natural join activity_timepoint_file
                natural join activity_timepoint
        where
            series_instance_uid = $1
    """

    tp_query = """\
        select distinct
                activity_id,
                activity_timepoint_id,
                when_created,
                creating_user
        from
            file_series
                natural join activity_timepoint_file
                natural join activity_timepoint
        where
            series_instance_uid = $1
    """

    # convert to true python objects so Pydantic verification works
    activities = [x['activity_id'] for x in 
                  await db.fetch(act_query, [series_instance_uid])]

    timepoints = [dict(x) for x in await db.fetch(tp_query, [series_instance_uid])]

    return {
        "activities": activities,
        "timepoints": timepoints,
    }
