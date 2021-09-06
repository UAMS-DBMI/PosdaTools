from fastapi import Depends, APIRouter, HTTPException, Form, Request
from pydantic import BaseModel

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database

import json


@router.get("/items")
async def get_work_status(status: str, count: int = 20, db: Database = Depends()):
    query = f"""
        select
            work_id
        from
            work
        where
            status = $1
        limit {count}
    """

    results = await db.fetch(query, [status])
    return [i[0] for i in results]

@router.get("/items/{work_id}")
async def get_work_status(work_id: int, db: Database = Depends()):
    query = """
          select
                work.*,
                background_subprocess_id,
                activity_id,
                invoking_user,
                now() - when_invoked as since_invocation,
                command_line,
                when_invoked,
                user_to_notify,
                node_hostname
            from
                work
                left join subprocess_invocation using (subprocess_invocation_id)
                left join background_subprocess using (subprocess_invocation_id)
                left join activity_task_status using (subprocess_invocation_id)
            where work_id = $1
    """
    return await db.fetch_one(query, [work_id])

@router.get("/queues/{queue_name}")
async def get_work_status(queue_name: str, count: int = 20, db: Database = Depends()):
    query = f"""
        select
            work_id
        from
            work
        where
            background_queue_name = $1
            and finished = false
            and running = false
            and failed = false
        order by work_id desc
        limit {count}
    """

    results = await db.fetch(query, [queue_name])
    return [i[0] for i in results]
