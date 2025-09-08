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


@router.get("/find_segs_in_activity/{activity_id}")
async def find_segs_in_activity(activity_id: int, db: Database = Depends()):
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
    return await db.fetch(query, [activity_id])

@router.get("/getLatestFileForSop/{sop_instance_uid}")
async def getLatestFileForSop(sop_instance_uid: str, db: Database = Depends()):
    query = """\
        select max(file_id) as file_id
        from file_sop_common
        where sop_instance_uid = $1;
        """
    return await db.fetch(query, [sop_instance_uid])

@router.get("/getFORfromfile/{file_id}")
async def getFORfromfile(file_id: int, db: Database = Depends()):
    query = """\
            select for_uid from file_for ff where file_id  = $1;
        """
    return await db.fetch(query, [file_id])

@router.get("/getSeries/{file_id}")
async def getSeries(file_id: int, db: Database = Depends()):
    query = """\
            select series_instance_uid
            from file_series 
            natural join file
            where file_id = $1;
        """
    return await db.fetch(query, [file_id])

@router.put("/populate_seg_linkages/{file_id}/{seg_id}/{linked_sop_instance_uid}/{linked_sop_class_uid}")
async def populate_seg_linkages(file_id: int, seg_id: int, linked_sop_instance_uid: str, linked_sop_class_uid: str, db: Database = Depends()):
       query = """\
            INSERT INTO public.file_seg_image_linkage
            (file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid)
            VALUES($1, $2, $3, $4)
            ON CONFLICT (file_id,seg_id) DO UPDATE SET
              linked_sop_instance_uid=EXCLUDED.linked_sop_instance_uid,
              linked_sop_class_uid=EXCLUDED.linked_sop_class_uid;
            """
       return await db.fetch(query, [file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid ])
