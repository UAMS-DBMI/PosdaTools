from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse
from .auth import logged_in_user, User

from ..util import Database, asynctar, roi

router = APIRouter(
    tags=["Segmentation"],
    dependencies=[logged_in_user]
)


@router.get("/")
async def test():
    raise HTTPException(detail="test error, not allowed", status_code=401)

@router.get("/series/{series_instance_uid}")
async def get_segs_for_series(series_instance_uid: str, db: Database = Depends()):
    query = """\
        select
            seg_id,
            array_agg(file_sop_common.file_id) as file_ids
        from file_series
        natural join file_sop_common
        join file_seg_image_linkage
            on linked_sop_instance_uid = sop_instance_uid
        where series_instance_uid = $1
        group by seg_id
        order by seg_id
    """

    results = await db.fetch(query, [series_instance_uid])
    seg_links = []
    for result in results:
        r = {}
        r['seg_id'] = result['seg_id']
        r['file_ids'] = result['file_ids']
        rois.append(r)

    return seg_links


@router.get("/sop/{sop_instance_uid}")
async def get_seg_ids_for_linked_sop(sop_instance_uid: str, db: Database = Depends()):
    query = """\
        select
            seg_id,
            array_agg(file_sop_common.file_id) as file_ids
        from file_series
        natural join file_sop_common
        join file_seg_image_linkage
            on linked_sop_instance_uid = ?
        group by seg_id
        order by seg_id
    """

    results = await db.fetch(query, [series_instance_uid])
    seg_links = []
    for result in results:
        r = {}
        r['seg_id'] = result['seg_id']
        r['file_ids'] = result['file_ids']
        rois.append(r)
    return seg_links


@router.get("/file/{file_id}")
async def get_file_from_sop(file_id: int, db: Database = Depends()):
    ret = await db.fetch_one("""\
        select sop_instance_uid
        from file_sop_common
        where file_id = $1
    """, [file_id])
    return await get_file_from_sop(ret['sop_instance_uid'], db)

@router.get("/find_segs_in_activity/{activity_id}")
async def find_segs_in_activity(activity_id: int, db: Database = Depends()):
        #find files
        f = {}
        query = """\
            select
              file_id,
              root_path || '/' || rel_path as path
            from
              file_storage_root natural join file_location
            where file_id in (
              select distinct file_id
              from dicom_file df natural join ctp_file natural join activity_timepoint_file
              where
              dicom_file_type = 'Segmentation Storage'
              and has_no_roi_linkages is null
              and not exists (
                select file_id from file_roi_image_linkage r where r.file_id = df.file_id
              )
              and activity_timepoint_id = (
                select max(activity_timepoint_id) as activity_timepoint_id
                from activity_timepoint
                where activity_id = $1
              )
            );
            """
    return await find_segs_in_activity(query['activity_id'], db)

@router.put("/populate_seg_linkages/{file_id}/{seg_id}/{linked_sop_instance_uid}/{linked_sop_class_uid}")
async def populate_seg_linkages(activity_name: str, user: str, db: Database = Depends()):
       query = """\
            INSERT INTO public.file_seg_image_linkage
            (file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid)
            VALUES($1, $2, $3, $4);
            """
       return await populate_seg_linkages(query['file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid'], db)
