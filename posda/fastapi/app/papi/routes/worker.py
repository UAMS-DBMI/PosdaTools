from fastapi import Depends, APIRouter, HTTPException

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database


@router.get("/status/{work_id}")
async def get_work_status(work_id: int, db: Database = Depends()):
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
        from
            work
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id])

@router.get("/subprocess/{subprocess_invocation_id}")
async def get_subprocess_info(subprocess_invocation_id: int, db: Database = Depends()):
    query = """
        select
            *
        from
            subprocess_invocation
        where
            subprocess_invocation_id = $1
    """

    return await db.fetch_one(query, [subprocess_invocation_id])
