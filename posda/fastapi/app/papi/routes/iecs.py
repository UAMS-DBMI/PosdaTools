from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse

from .auth import logged_in_user, User
from ..util import Database

from ..util.models import File, FrameResponse, consistent

import numpy as np
from dataclasses import dataclass, asdict
from collections import defaultdict



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


@router.get("/{iec}/frames")
async def get_iec_frames(iec: int, include_frames: bool = True, db: Database = Depends()) -> FrameResponse:
    """Get a list of frames (files and frame counts) from this IEC.

    Also returns a guess for if the data is intended to be volumetric.
    """

    query = """
        select
            file_id,
            image_type,
            coalesce(number_of_frames, 1) as frame_count,
            iop,
            ipp
        from
            image_equivalence_class_input_image
            natural left join file_image
            natural left join image
            natural left join image_geometry
        where
            image_equivalence_class_id = $1
    """

    def raw_to_obj(rows):
        return [File.from_raw(*i) for i in rows]

    framelist = raw_to_obj([list(x) for x in await db.fetch(query, [iec])])
    if len(framelist) < 1:
        raise HTTPException(detail="no records returned", status_code=404)

    sorted_framelist, consistent_frames = consistent(framelist)

    if include_frames:

        simplified = [
            { 
                "file_id": x.file_id,
                "num_of_frames": x.frame_count,
            }
            for x in sorted_framelist
        ]

        return {
            "volumetric": consistent_frames,
            "frames": simplified,
        }

    else:
        return {
            "volumetric": consistent_frames,
        }


@router.get("/{iec}/info")
async def get_iec_info(iec: int, db: Database = Depends()):
    """Get details for an IEC.
    """

    frames = await get_iec_frames(iec=iec, include_frames=False, db=db)

    query = """
        with iec_image_count as (
            select image_equivalence_class_id, count(file_id) as file_count
            from image_equivalence_class_input_image
            group by image_equivalence_class_id
        ),
        series_info as (
            select
                series_instance_uid,
                body_part_examined,
                modality,
                patient_id,
                series_description
            from file_series
            natural left join file_patient
        )
        select distinct on (iec.image_equivalence_class_id)
            iec.visual_review_instance_id,
            iec.image_equivalence_class_id,
            iec.series_instance_uid,
            iec.equivalence_class_number,
            iec.processing_status,
            iec.review_status,
            iec_out.projection_type,
            fl.file_id,
            coalesce(fsr.root_path || '/' || fl.rel_path, NULL) as path,
            iec.update_user,
            to_char(iec.update_date, 'YYYY-MM-DD HH:MI:SS AM') as update_date,
            iic.file_count,
            si.body_part_examined,
            si.modality,
            si.patient_id,
            si.series_description
        from image_equivalence_class iec
        left join image_equivalence_class_out_image iec_out using (image_equivalence_class_id)
        left join file_location fl using (file_id)
        left join file_storage_root fsr using (file_storage_root_id)
        left join iec_image_count iic using (image_equivalence_class_id)
        left join series_info si on si.series_instance_uid = iec.series_instance_uid
        where iec.image_equivalence_class_id = $1
    """

    item = dict(await db.fetch_one(query, [iec]))

    if item:
        item['download_path'] = f"/papi/v1/files/iec/{iec}"
        item['download_name'] = f"iec_{iec}.zip"
        item['volumetric'] = frames['volumetric']

    return item

class IECSeries(BaseModel):
    file_count: int
    image_equivalence_class_id: int
    series_description: str

# For a list of series
IECSeriesList = List[IECSeries]


@router.get("/{iec}/other_iecs_in_for", response_model=IECSeriesList)
async def iecs_for_for(
    iec: int,
    db: Database = Depends(),
):
    """
    Get all other IECs that share this IEC's Frame of Reference

    For the given IEC, this returns a list of all IECs (other than
    the original one) inside the same visual review that share a
    Frame of Reference.
    """
    query = """\
        with seg_for as (
            select distinct for_uid, visual_review_instance_id
            from image_equivalence_class_input_image
            natural join image_equivalence_class
            natural join file_for
            where image_equivalence_class_id = $1
            limit 1
        ), candidate_files as (
            select file_id, image_equivalence_class_id
            from image_equivalence_class
            natural join image_equivalence_class_input_image
            where visual_review_instance_id = (select visual_review_instance_id from seg_for)
        )

        select image_equivalence_class_id, series_description, count(file_id) as file_count
        from candidate_files
        natural join file_for
        natural join file_series
        where for_uid = (select for_uid from seg_for)
        and image_equivalence_class_id != $1
        group by 1, 2
        order by file_count desc
    """

    return [dict(i) for i in await db.fetch(query, [iec])]
