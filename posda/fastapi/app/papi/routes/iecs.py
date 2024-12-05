from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse

from .auth import logged_in_user, User
from ..util import Database

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


class Frame(BaseModel):
    file_id: int
    num_of_frames: int

class FrameResponse(BaseModel):
    volumetric: bool
    frames: list[Frame]


@dataclass
class File:
    file_id: int
    image_type: list[str]
    frame_count: int
    orientation: list
    position: list

    def from_raw(tup):
        file_id, image_type, num_frames, iop, ipp = tup

        if num_frames is None:
            num_frames = 1
        else:
            num_frames = int(num_frames)

        image_types = image_type.split('\\')

        # iop and ipp need to be broken into lists
        iop_parts = iop.split('\\')
        orientation = [float(i) for i in iop_parts]

        ipp_parts = ipp.split('\\')
        position = [float(i) for i in ipp_parts]

        return File(file_id, image_types, num_frames, orientation, position)

    def normals(self):
        return np.cross(self.orientation[:3], self.orientation[3:])

    def projected_position(self):
        return np.dot(self.position, self.normals())



def consistent(file_objs) -> tuple[list[File], bool]:
    """Detect if the list of frames is consistent or not.

    Also returns the list sorted appropriately by projecting 
    with the iop/ipp
    """

    # not enough slices to have any idea
    if len(file_objs) < 2:
        return (file_objs, False)

    sorted_by_proj_position = sorted(file_objs, key=lambda x: x.projected_position())

    all_positions = [i.projected_position() for i in sorted_by_proj_position]

    all_differences = np.diff(all_positions, axis=0)

    consistent_slices = np.allclose(all_differences, all_differences[0], atol=1e-3)

    return (sorted_by_proj_position, consistent_slices)


@router.get("/{iec}/frames")
async def get_iec_frames(iec: int, db: Database = Depends()) -> FrameResponse:
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
            natural left join file_image_geometry
            natural left join image_geometry
        where
            image_equivalence_class_id = $1
    """

    def raw_to_obj(rows):
        return [File.from_raw(i) for i in rows]

    framelist = raw_to_obj([list(x) for x in await db.fetch(query, [iec])])
    if len(framelist) < 1:
        raise HTTPException(detail="no records returned", status_code=404)

    sorted_framelist, consistent_frames = consistent(framelist)

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


@router.get("/{iec}/info")
async def get_iec_info(iec: int, db: Database = Depends()):
    """Get details for an IEC.
    """

    query = """
    select
        image_equivalence_class_id,
        series_instance_uid,
        equivalence_class_number,
        processing_status,
        review_status,
        projection_type,
        file_id,
        root_path || '/' || rel_path as path,
        update_user,
        to_char(update_date, 'YYYY-MM-DD HH:MI:SS AM') as update_date,
        (select count(file_id)
            from image_equivalence_class_input_image i
            where i.image_equivalence_class_id =
                image_equivalence_class.image_equivalence_class_id) as file_count,
        (select body_part_examined
            from file_series
            where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as body_part_examined,
            (select patient_id
            from file_patient
            natural join file_series
            where file_series.series_instance_uid = image_equivalence_class.series_instance_uid limit 1) as patient_id
    from image_equivalence_class    
    natural join image_equivalence_class_out_image
    natural join file_location
    natural join file_storage_root
    where image_equivalence_class_id = $1
    """

    item = dict(await db.fetch_one(query, [iec]))
    
    if item:
        item['download_path'] = f"/papi/v1/files/iec/{iec}"
        item['download_name'] = f"iec_{iec}.zip"

    return item