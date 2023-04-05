from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime

from .auth import logged_in_user, User
from ..util import Database

router = APIRouter(
    tags=["Studies"],
    dependencies=[logged_in_user]
)


@router.get("/")
async def get_all_studies():
    raise HTTPException(detail="listing all studies is not allowed", status_code=401)


class StudyDetail(BaseModel):
    series_count: int
    study_date: datetime.date
    study_time: str

@router.get("/{study_instance_uid}")
async def get_single_study(study_instance_uid: str, db: Database = Depends()) -> StudyDetail:
    query = """
        select
            study_date,
            study_time::text,
            count(distinct series_instance_uid) as series_count
        from file_study
        natural join file_series
        where study_instance_uid = $1
        group by
            study_date,
            study_time
    """

    result = await db.fetch_one(query, [study_instance_uid])
    return StudyDetail(**result)


class SeriesInfo(BaseModel):
    series_instance_uid: str

@router.get("/{study_instance_uid}/series", response_model=List[SeriesInfo])
async def get_all_series(study_instance_uid: str, db: Database = Depends()) -> List[SeriesInfo]:
    query = """
        select distinct
            series_instance_uid
        from file_study
        natural join file_series
        where study_instance_uid = $1
    """

    return await db.fetch(query, [study_instance_uid])
