from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from .auth import logged_in_user, User

from ..util import Database

router = APIRouter()
images = {}
current_user:User = logged_in_user


@router.get("/start/{vr_id}")
async def get_files_for_review(vr_id: int, db: Database = Depends()):
    query = """\
        select distinct
          path_file_id
        from
          pathology_visual_review_files
        where
          pathology_visual_review_instance_id = $1
    """
    return await db.fetch(query, [vr_id])



@router.get("/preview_file_name/{pathid}")
async def get_filename(pathid: int, db: Database = Depends()):
    query = """\
         select
            file_name, good_status
        from
            file_import a
            left join pathology_visual_review_status b on a.file_id = b.file_id
        where
            a.file_id = $1
             """
    return await db.fetch(query, [pathid])

@router.get("/preview/{pathid}/{vr_id}")
async def get_previews(pathid: int, vr_id: int, db: Database = Depends()):
    query = """\
        select
         distinct preview_file_id
        from
        	pathology_visual_review_files
        where
        	path_file_id = $1
            and pathology_visual_review_instance_id = $2
        """
    return await db.fetch(query, [pathid, vr_id])

@router.put("/set_edit/{pathid}/good")
async def set_editG(pathid: int,  db: Database = Depends()):
    record = await db.fetch("""\
        INSERT INTO pathology_visual_review_status
        VALUES($1 , true, $2, now());
        """, [pathid, current_user.username])

    print(record)
    if len(record) < 1:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {
        'status': 'success',
    }

@router.put("/set_edit/{pathid}/bad")
async def set_editB(pathid: int, db: Database = Depends()):
    record = await db.fetch("""\
        INSERT INTO pathology_visual_review_status
        VALUES($1 , false, $2, now());
        """, [pathid,current_user.username])
    print(record)
    if len(record) < 1:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {
        'status': 'success',
    }

@router.get("/review/{vr_id}")
async def review(vr_id: int, db: Database = Depends()):
    query = """\
    select distinct
        d.file_name,
        good_status
    from
        pathology_visual_review_files b
        left join file_import d on d.file_id = b.path_file_id
        left join pathology_visual_review_status c on b.path_file_id = c.file_id
    where
        pathology_visual_review_instance_id = $1
      """
    return await db.fetch(query, [vr_id])

@router.get("/getcount")
def get_current_count():
    return len(images)
