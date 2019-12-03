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
async def get_all_files(series_instance_uid: str, db: Database = Depends()):
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
