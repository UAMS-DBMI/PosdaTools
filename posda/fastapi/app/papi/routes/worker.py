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

@router.post("/status/{work_id}/running")
async def set_work_status_running(work_id: int, db: Database = Depends()):
    query = """
        update
            work
        set
            running = true,
            status = 'running'
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id])

@router.post("/status/{work_id}/finished")
async def set_work_status_finished(work_id: int, db: Database = Depends()):
    query = """
        update
            work
        set
            running = false,
            finished = true,
            status = 'finished'
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id])


class ErrorFile(BaseModel):
    stderr_file_id: int

@router.post("/status/{work_id}/errored")
async def set_work_status_errored(error_file: ErrorFile, work_id: int, db: Database = Depends()):
    query = """
        update
            work
        set
            running = false,
            errored = true,
            status = 'errored'
            stderr_file_id = $2
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id, error_file.stderr_file_id])

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
