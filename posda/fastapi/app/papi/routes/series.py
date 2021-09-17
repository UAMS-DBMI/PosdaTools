from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database


@router.get("/")
async def get_all_studies():
    raise HTTPException(detail="listing all series is not allowed", status_code=401)

@router.get("/{series_instance_uid}")
async def get_single_series(series_instance_uid: str, db: Database = Depends()):
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


@router.get("/{series_instance_uid}/files")
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

    Additionally, an activity_timepoint_id can be given by appending it
    to the series after a colon, such as:

    "1.2.3.4553452342234:13"
     
    This will take precedence over all other timepoint directives.

    """
    if ":" in series_instance_uid:
        series_instance_uid, activity_timepoint_id = series_instance_uid.split(':')

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

    return {"file_ids": [x[0] for x in await db.fetch(query, [series_instance_uid])]}
