from fastapi import Depends, APIRouter, HTTPException, Form, Request
from pydantic import BaseModel

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database

import json


@router.get("/status/{work_id}")
async def get_work_status(work_id: int, db: Database = Depends()):
    query = """
        select
            work_id,
            node_hostname,
            subprocess_invocation_id,
            input_file_id,
            status,
            running,
            finished,
            failed,
            stderr_file_id,
            stdout_file_id
        from
            work
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id])

class RunningDetails(BaseModel):
    node_hostname: str = None

@router.post("/status/{work_id}/running")
async def set_work_status_running(details: RunningDetails, work_id: int, db: Database = Depends()):
    query = """
        update
            work
        set
            running = true,
            status = 'running',
            node_hostname = $1
        where
            work_id = $2
    """
    return await db.fetch_one(query, [details.node_hostname, work_id])

class ErrorFiles(BaseModel):
    stderr_file_id: int = None
    stdout_file_id: int = None

@router.post("/status/{work_id}/finished")
async def set_work_status_finished(request: Request, error_files: ErrorFiles, work_id: int, db: Database = Depends()):
    json_body = await request.json()
    # these two items are tracked directly, no need
    # for them to also be in the metrics field
    del json_body['stderr_file_id']
    del json_body['stdout_file_id']
    json_body_str = json.dumps(json_body)

    query = """
        update
            work
        set
            running = false,
            finished = true,
            status = 'finished',
            stderr_file_id = $2,
            stdout_file_id = $3,
            metrics = $4
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id, error_files.stderr_file_id, error_files.stdout_file_id, json_body_str])

@router.post("/status/{work_id}/errored")
async def set_work_status_errored(request: Request, error_files: ErrorFiles, work_id: int, db: Database = Depends()):

    json_body = await request.json()
    # these two items are tracked directly, no need
    # for them to also be in the metrics field
    del json_body['stderr_file_id']
    del json_body['stdout_file_id']
    json_body_str = json.dumps(json_body)

    query = """
        update
            work
        set
            running = false,
            failed = true,
            status = 'errored',
            stderr_file_id = $2,
            stdout_file_id = $3,
            metrics = $4
        where
            work_id = $1
    """
    return await db.fetch_one(query, [work_id, error_files.stderr_file_id, error_files.stdout_file_id, json_body_str])

@router.get("/subprocess/{subprocess_invocation_id}")
async def get_subprocess_info(subprocess_invocation_id: int, db: Database = Depends()):
    query = """
        select
            subprocess_invocation_id,
            command_line
        from
            subprocess_invocation
        where
            subprocess_invocation_id = $1
    """

    return await db.fetch_one(query, [subprocess_invocation_id])
