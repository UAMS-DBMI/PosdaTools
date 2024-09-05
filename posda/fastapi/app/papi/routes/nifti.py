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
        select fi.file_name, 
               fsr.root_path, 
               fl.rel_path
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




# @router.get("/review/{vr_id}")
# async def review(vr_id: int, db: Database = Depends()):
#     query = """\
#     select distinct
#         fi.file_name,
#         nvrs.good_status
#     from
#         nifti_visual_review_files nvrf
#         left join file_import fi 
#         on fi.file_id = nvrf.path_file_id
#         left join nifti_visual_review_status nvrs 
#         on nvrf.path_file_id = nvrs.path_file_id
#     where
#         nvrf.nifti_visual_review_instance_id = $1
#       """
#     return await db.fetch(query, [vr_id])






# @router.get("/mapping/{file_id}")
# async def get_mapping(file_id: int, db: Database = Depends()):
#     query = """\
#          select
#             patient_id
#         from
#             pathology_patient_mapping a
#         where
#             a.file_id = $1
#              """
#     return await db.fetch(query, [file_id])

# @router.get("/image_desc/{file_id}")
# async def get_image_desc(file_id: int, db: Database = Depends()):
#     query = """\
#          select
#             image_desc
#         from
#             pathology_image_desc a
#         where
#             a.file_id = $1
#              """
#     return await db.fetch(query, [file_id])


# @router.get("/getcount")
# def get_current_count():
#     return len(images)

# @router.get("/find_files/{activity_id}")
# async def find_files(activity_id: int, db: Database = Depends()):
#     query = """\
#         select f.file_id from file f join activity_timepoint_file atf  on f.file_id = atf.file_id
#             where atf.activity_timepoint_id in (
#                 select
#                     max(activity_timepoint_id) as activity_timepoint_id
#                 from
#                     activity_timepoint
#                 where
#                     activity_id = $1
#               );
#         """
#     return await db.fetch(query, [activity_id])

# @router.get("/find_edits/{file_id}")
# async def find_edits(file_id: int, db: Database = Depends()):
#     query = """\
#      select pathology_edit_queue_id, edit_type, edit_details
#             from pathology_edit_queue
#              where
#                  file_id = $1
#                  and status = 'waiting'
#     """
#     return await db.fetch(query, [file_id])

# @router.get("/find_relpath/{file_id}")
# async def find_relpath(file_id: int, db: Database = Depends()):
#     query = """\
#       select root_path, rel_path
#       from file_location f
#       natural join file_storage_root fsr
#       where f.file_id = $1
#      """
#     return await db.fetch(query, [file_id])

# @router.patch("/completeEdit/{edit_id}")
# async def completeEdit(edit_id: int, db: Database = Depends()):
#         record = await db.fetch("""\
#         update pathology_edit_queue set status = 'complete' where pathology_edit_queue_id = $1 returning pathology_edit_queue_id;
#         """, [edit_id])

#         if len(record) < 1:
#             raise HTTPException(detail="Complete Edit: Error updating edit status", status_code=422)

#         return {
#            'status': 'success',
#         }

# @router.put("/create_path_activity_timepoint/{activity_id}/{user}")
# async def create_path_activity_timepoint(activity_id: int, user: str, db: Database = Depends()):
#        query = """\
#             insert into activity_timepoint(
#                 activity_id,
#                 when_created,
#                 who_created,
#                 comment,
#                 creating_user
#             ) values (
#                 $1, now(), $2, 'Post Edit Pathology TP', $2)
#             returning activity_timepoint_id;
#             """
#        return await db.fetch(query, [activity_id, user])

# @router.put("/add_file_to_path_activity_timepoint/{atf_id}/{file_id}")
# async def add_file_to_path_activity_timepoint(atf_id: int, file_id: int, db: Database = Depends()):
#          query = """\
#                     insert into activity_timepoint_file(
#                          activity_timepoint_id,
#                          file_id
#                         ) values (
#                           $1, $2)
#                     returning file_id;
#                     """
#          return await db.fetch(query, [atf_id, file_id])
