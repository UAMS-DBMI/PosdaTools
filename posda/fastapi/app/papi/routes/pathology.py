from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()
images = {}

from .auth import logged_in_user, User

from ..util import Database


@router.get("/start/{vr_id}")
async def get_files_for_review(vr_id: int, db: Database = Depends()):
    query = """\
        select distinct
          svsfile_id
        from
          pathology_visual_review_files
        where
          pathology_visual_review_instance_id = $1
    """
    return await db.fetch(query, [vr_id])



# @router.get("/kohlrabi/{svsid}")
# async def get_preview_filepaths(svsid: int, db: Database = Depends()):
#     query = """\
#         select
#          root_path || '/' || rel_path as filepath
#         from
#         	pathology_visual_review_files
#         	join file
#         		on pathology_visual_review_files.preview_file_id = file.file_id
#         	natural join file_location
#         	natural join file_storage_root
#         where
#         	svsfile_id = $1
#         """
#     return await db.fetch(query, [svsid])

@router.get("/preview/{svsid}")
async def get_previews(svsid: int, db: Database = Depends()):
    query = """\
        select
         distinct preview_file_id
        from
        	pathology_visual_review_files
        where
        	svsfile_id = $1
        """
    return await db.fetch(query, [svsid])

@router.put("/set_edit/{svsid}/good")
async def set_editG(svsid: int,  db: Database = Depends()):
    record = await db.fetch("""\
        update
            pathology_visual_review_files
        set
            needs_edit = false
        where
            svsfile_id = $1
        returning 1
        """, [svsid])

    print(record)
    if len(record) < 1:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {
        'status': 'success',
    }

@router.put("/set_edit/{svsid}/bad")
async def set_editB(svsid: int, db: Database = Depends()):
    record = await db.fetch("""\
        update
            pathology_visual_review_files
        set
            needs_edit = true
        where
            svsfile_id = $1
        returning 1
        """, [svsid])
    print(record)
    if len(record) < 1:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {
        'status': 'success',
    }

@router.get("/review/{vr_id}/{status}")
async def review(vr_id: int, status: str, db: Database = Depends()):
    query = """\
        select
            file_name
        from
            pathology_visual_review_instance
            natural join pathology_visual_review_files
            join file_import on svsfile_id = file_id
        where
            pathology_visual_review_instance_id = $1
            and needs_edit"""

    if status == "good":
        query = query + " = false"
    elif status == "bad":
        query = query + " = true"
    else:
        query = query + " is null"

    return await db.fetch(query, [vr_id])


@router.get("/getcount")
def get_current_count():
    return len(images)
