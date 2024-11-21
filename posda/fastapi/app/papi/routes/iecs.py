from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse

from .auth import logged_in_user, User
from ..util import Database

router = APIRouter(
    tags=["Image Equivalence Classes (IEC)"],
    dependencies=[logged_in_user]
)

@router.get("/")
async def get_all_iecs(request, **kwargs):
    return HTTPException(detail="listing all iecs is not allowed", status_code=401)

@router.get("/{iec}")
async def get_iec_details(iec: int, db: Database = Depends()):
    query = """
        select *
        from image_equivalence_class
        where image_equivalence_class_id = $1
    """

    return await db.fetch(query, [iec])

@router.get("/{iec}/files")
async def get_iec_files(iec: int, db: Database = Depends()):
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

    return {"file_ids": [x[0] for x in await db.fetch(query, [iec])]}


class Frame(BaseModel):
    file_id: int
    frames: int


@router.get("/{iec}/frames")
async def get_iec_frames(iec: int, db: Database = Depends()) -> list[Frame]:
    query = """
    select
        file_id,
        coalesce(number_of_frames, 1) as frames
    from
        image_equivalence_class_input_image
        natural join file_sop_common
        natural left join file_image
        natural left join image
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

    return [dict(x) for x in await db.fetch(query, [iec])]
