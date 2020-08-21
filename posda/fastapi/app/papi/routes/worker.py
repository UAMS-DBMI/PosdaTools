from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database


class WorkInfo(BaseModel):
    work_id: int
    node_hostname: str
    subprocess_invocation_id: int
    status: str
    running: bool
    finished: bool
    failed: bool
    stderr_file_id: int

@router.get("/status/{work_id}", response_model=WorkInfo)
async def get_work_status(work_id: int, db: Database = Depends()) -> WorkInfo:
    query = """
        select
            work_id,
            node_hostname,
            subprocess_invocation_id,
            status,
            running,
            finished,
            failed,
            stderr_file_id
        from work
        where work_id = $1
    """
    return await db.fetch(query, [work_id])
