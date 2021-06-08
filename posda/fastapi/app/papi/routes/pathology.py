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



@router.get("/preview_file_name/{svsid}")
async def get_filename(svsid: int, db: Database = Depends()):
    query = """\
         select
            file_name, good
        from
            file_import
            left join pathology_visual_review_status on file_id = svsfile_id
        where
            file_id = $1
             """
    return await db.fetch(query, [svsid])

@router.get("/preview/{svsid}/{vr_id}")
async def get_previews(svsid: int, vr_id: int, db: Database = Depends()):
    query = """\
        select
         distinct preview_file_id
        from
        	pathology_visual_review_files
        where
        	svsfile_id = $1
            and pathology_visual_review_instance_id = $2
        """
    return await db.fetch(query, [svsid, vr_id])

@router.put("/set_edit/{svsid}/good")
async def set_editG(svsid: int,  db: Database = Depends()):
    record = await db.fetch("""\
        INSERT INTO pathology_visual_review_status (svsfile_id, good)
        VALUES($1 , true)
        ON CONFLICT (svsfile_id)
        DO
           UPDATE SET good = true;
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
        INSERT INTO pathology_visual_review_status (svsfile_id, good)
        VALUES($1 , false)
        ON CONFLICT (svsfile_id)
        DO
           UPDATE SET good = false;
        """, [svsid])
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
      b.svsfile_id , good
    from
      pathology_visual_review_files b
      left join pathology_visual_review_status c on b.svsfile_id = c.svsfile_id
    where
      pathology_visual_review_instance_id = $1
      """
    return await db.fetch(query, [vr_id])

@router.get("/getcount")
def get_current_count():
    return len(images)
