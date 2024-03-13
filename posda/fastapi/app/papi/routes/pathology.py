from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from .auth import logged_in_user, User

from ..util import Database

router = APIRouter(
    tags=["Pathology"],
    dependencies=[logged_in_user]
)

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
            left join pathology_visual_review_status b on a.file_id = b.path_file_id
        where
            a.file_id = $1
             """
    return await db.fetch(query, [pathid])

@router.get("/preview/{pathid}/{gammaIndex}")
async def get_previews(pathid: int, gammaIndex: int, db: Database = Depends()):
    query = """\
        select
         distinct preview_file_id
        from
        	pathology_visual_review_preview_files
        where
        	path_file_id = $1
            and gammaindex = $2
        """
    return await db.fetch(query, [pathid,gammaIndex])

@router.put("/set_edit/{pathid}/{good_status}/{user}")
async def set_edit(pathid: int, good_status: bool ,user: str, db: Database = Depends()):
    record = await db.fetch("""\
        INSERT INTO pathology_visual_review_status
        VALUES($1 , $2, $3, now());
        """, [pathid, good_status, user])

    print(record)
    if len(record) < 1:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {
        'status': 'success',
    }

@router.put("/remM/{pathid}")
async def remM(pathid: int,  db: Database = Depends()):
    record = await db.fetch("""\
        INSERT INTO pathology_edit_queue
        (file_id,edit_type, edit_details, status)
        VALUES($1 , 1, NULL, 'waiting');
        """, [pathid])

    print(record)
    if len(record) < 1:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {
        'status': 'success',
    }

@router.put("/remL/{pathid}")
async def remL(pathid: int, db: Database = Depends()):
    record = await db.fetch("""\
        INSERT INTO pathology_edit_queue
        (file_id,edit_type, edit_details, status)
        VALUES($1 , 2, NULL, 'waiting');
        """, [pathid])

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
        pathology_visual_review_preview_files b
        left join file_import d on d.file_id = b.path_file_id
        left join pathology_visual_review_status c on b.path_file_id = c.path_file_id
    where
        pathology_visual_review_instance_id = $1
      """
    return await db.fetch(query, [vr_id])

@router.get("/mapping/{file_id}")
async def get_mapping(file_id: int, db: Database = Depends()):
    query = """\
         select
            patient_id
        from
            pathology_patient_mapping a
        where
            a.file_id = $1
             """
    return await db.fetch(query, [file_id])

@router.get("/image_desc/{file_id}")
async def get_image_desc(file_id: int, db: Database = Depends()):
    query = """\
         select
            image_desc
        from
            pathology_image_desc a
        where
            a.file_id = $1
             """
    return await db.fetch(query, [file_id])


@router.get("/getcount")
def get_current_count():
    return len(images)

@router.get("/find_files/{activity_id}")
async def find_files(activity_id: int, db: Database = Depends()):
    query = """\
        select f.file_id from file f join activity_timepoint_file atf  on f.file_id = atf.file_id
            where atf.activity_timepoint_id in (
                select
                    max(activity_timepoint_id) as activity_timepoint_id
                from
                    activity_timepoint
                where
                    activity_id = $1
              );
        """
    return await db.fetch(query, [activity_id])

@router.get("/find_edits/{file_id}")
async def find_edits(file_id: int, db: Database = Depends()):
    query = """\
     select pathology_edit_queue_id, edit_type, edit_details
            from pathology_edit_queue
             where
                 file_id = $1
                 and status = 'waiting'
    """
    return await db.fetch(query, [file_id])

@router.get("/find_relpath/{file_id}")
async def find_relpath(file_id: int, db: Database = Depends()):
    query = """\
      select root_path, rel_path
      from file_location f
      natural join file_storage_root fsr
      where f.file_id = $1
     """
    return await db.fetch(query, [file_id])

@router.patch("/completeEdit/{edit_id}")
async def completeEdit(edit_id: int, db: Database = Depends()):
        record = await db.fetch("""\
        update pathology_edit_queue set status = 'complete' where pathology_edit_queue_id = $1 returning pathology_edit_queue_id;
        """, [edit_id])

        if len(record) < 1:
            raise HTTPException(detail="Complete Edit: Error updating edit status", status_code=422)

        return {
           'status': 'success',
        }

@router.put("/create_path_activity_timepoint/{activity_id}/{user}")
async def create_path_activity_timepoint(activity_id: int, user: str, db: Database = Depends()):
       query = """\
            insert into activity_timepoint(
                activity_id,
                when_created,
                who_created,
                comment,
                creating_user
            ) values (
                $1, now(), $2, 'Post Edit Pathology TP', $2)
            returning activity_timepoint_id;
            """
       return await db.fetch(query, [activity_id, user])

@router.put("/add_file_to_path_activity_timepoint/{atf_id}/{file_id}")
async def add_file_to_path_activity_timepoint(atf_id: int, file_id: int, db: Database = Depends()):
         query = """\
                    insert into activity_timepoint_file(
                         activity_timepoint_id,
                         file_id
                        ) values (
                          $1, $2)
                    returning file_id;
                    """
         return await db.fetch(query, [atf_id, file_id])
