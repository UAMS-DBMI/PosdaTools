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



@router.get("/{svsid}")
async def get_preview_filepaths(svsid: int, db: Database = Depends()):
    query = """\
        select
         root_path || '/' || rel_path as filepath
        from
        	pathology_visual_review_files
        	join file
        		on pathology_visual_review_files.preview_file_id = file.file_id
        	natural join file_location
        	natural join file_storage_root
        where
        	svsfile_id = $1
        """
    return await db.fetch(query, [svsid])

@router.get("/preview/{svsid}")
async def get_previews(svsid: int, db: Database = Depends()):
    query = """\
        select
         preview_file_id
        from
        	pathology_visual_review_files
        where
        	svsfile_id = $1
        """
    return await db.fetch(query, [svsid])


@router.get("/getcount")
def get_current_count():
    return len(images)
