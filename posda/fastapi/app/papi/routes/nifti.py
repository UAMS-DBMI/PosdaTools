import os
from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import datetime
from starlette.responses import Response, FileResponse
import asyncpg.exceptions

from .auth import logged_in_user, User
from ..util import Database

router = APIRouter(
    tags=["Functions for Nifti review"],
    dependencies=[logged_in_user]
)

# images = {}
# current_user:User = logged_in_user


# @router.get("/start/{vr_id}")
# async def get_files_for_review(vr_id: int, db: Database = Depends()):
#     query = """\
#         select distinct
#           nifti_file_id
#         from
#           nifti_visual_review_files
#         where
#           nifti_visual_review_instance_id = $1
#     """
#     return await db.fetch(query, [vr_id])

@router.get("/{nifti_id}")
async def get_nifti_details(
    nifti_id: int,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    
    """Return details about the given Nifti File
    """    

    query = """
        select fn.file_id,
               fi.file_name, 
               fsr.root_path, 
               fl.rel_path,
               fn.is_zipped
        from file_nifti fn
        natural join file_location fl
        natural join file_storage_root fsr
        left join file_import fi
        on fn.file_id = fi.file_id
        and fi.import_event_id = (
            select max(import_event_id)
            from file_import fi_sub
            where fi_sub.file_id = fn.file_id)
        where fn.file_id = $1        
    """

    item = dict(await db.fetch_one(query, [nifti_id]))

    if item:
        import_path, import_name = os.path.split(item["file_name"])
        item['import_path'] = import_path
        item['import_name'] = import_name
        item['download_path'] = f"/papi/v1/files/{nifti_id}/data"
        item['posda_path'] = f"{item['root_path']}/{item['rel_path']}"
    
    return item


@router.post("/{nifti_id}/set_status/{review_status}")
async def set_status(
    nifti_id: int, 
    review_status: str,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    
    """Update/Set Nifti review status"""
    
    #print(f"nifti_id: {nifti_id}, review_status: {review_status}, current_user: {current_user.username}")

    try:
        query = """\
            insert into nifti_visual_review_status (nifti_file_id, review_status, reviewing_user, review_time)
            values ($1, $2, $3, now())
            on conflict (nifti_file_id) 
            do update set 
                review_status = EXCLUDED.review_status,
                reviewing_user = EXCLUDED.reviewing_user,
                review_time = now();
        """
        await db.execute(query, [nifti_id, review_status, current_user.username])

        return {"message": "Nifti review status updated successfully"}

    except asyncpg.exceptions.ForeignKeyViolationError as e:
        raise HTTPException(detail="Invalid File ID supplied", status_code=422)
    except Exception as e:
        # Catch any other exceptions and log them if necessary
        print(f"An error occurred: {e}")
        raise HTTPException(detail="An unexpected error occurred", status_code=500)


@router.get("/visualreview/{nifti_visual_review_instance_id}")
async def get_for_visualreview(
    nifti_visual_review_instance_id: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """Return list of all Files in this Nifti VR
    """

    try:
        records = await db.fetch("""\
            select
                nifti_file_id
            from
                nifti_visual_review_files
                    natural left join nifti_visual_review_status
            where
                nifti_visual_review_instance_id = $1
                and nifti_visual_review_status.nifti_file_id is not null
        """, [nifti_visual_review_instance_id])

        return [x[0] for x in records]

    except:
        pass
