from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime

router = APIRouter()

from .auth import logged_in_user, User
from ..util import Database

@router.get("/")
async def get_all_studies():
    raise HTTPException(detail="test error, not allowed", status_code=401)

@router.get("/find_send_ready_to_begin_status_updates")
async def find_send_ready_to_begin_status_updates(db: Database = Depends()):
    query = """\
        select distinct
                subprocess_invocation_id
        from
                activity_task_status
                natural join public_copy_status
        where
                manual_update = true
    """

    return await db.fetch(query)




@router.get("/get_success_percentage_for_send/{subprocess_invocation_id}")
async def get_success_percentage_for_send(subprocess_invocation_id: int, db: Database = Depends()):
    query = """\
        select
            ('' || success::text || ' ' || ((count(*)/(select  sum(c) as t from
            ( select
                count(file_id) as c
                from
                    activity_timepoint_file
                where
                    activity_timepoint_id = (
                	select max(activity_timepoint_id)
                	from activity_timepoint
                	where activity_id = (
                		select activity_id
                		from activity_task_status
                		where subprocess_invocation_id = $1 )))
                		as sum_table)::float) * 100.0)::int || '%')::text as summary
        from
            public_copy_status
        where
            subprocess_invocation_id = $1
        group by
            success
            """
    return await db.fetch(query, [subprocess_invocation_id])

# TODO This method should be POST/PUT, not GET!
@router.get("/update_activity_status/{subprocess_invocation_id}/{new_status}")
async def update_activity_status(subprocess_invocation_id: int, new_status: str, db: Database = Depends()):
    query = """\
        update
            activity_task_status
        set
            status_text = $2
        where
            activity_task_status.manual_update = true
            and subprocess_invocation_id = $1
    """
    return await db.fetch(query, [subprocess_invocation_id, new_status])

@router.get("/finish_activity_status/{subprocess_invocation_id}")
async def finish_activity_status(subprocess_invocation_id: int, db: Database = Depends()):
    query = """\
        update
            activity_task_status
        set
            manual_update = false
        where
            activity_task_status.manual_update = true
            and subprocess_invocation_id = $1
    """

    return await db.fetch(query, [subprocess_invocation_id])
