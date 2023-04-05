from fastapi import Depends, APIRouter, HTTPException, Form, Request
from pydantic import BaseModel
import json

from .auth import logged_in_user, User
from ..util import Database

router = APIRouter(
    tags=["Defacing"],
    dependencies=[logged_in_user]
)


@router.get("/{defacing_id}")
async def get_work_status(defacing_id: int, db: Database = Depends()):
    query = """
        select *
        from
            file_nifti_defacing
        where
            file_nifti_defacing_id = $1
    """

    results = await db.fetch_one(query, [defacing_id])
    if len(results) < 1:
        raise HTTPException(detail="no such defacing_id", status_code=404)

    return results

class ErrorFiles(BaseModel):
    nifti_file_id: int = None
    three_d_rendered_face: int = None
    three_d_rendered_face_box: int = None
    three_d_rendered_defaced: int = None
    error_code: str = None


@router.post("/{defacing_id}/complete")
async def set_work_status_finished(request: Request, error_files: ErrorFiles, defacing_id: int, db: Database = Depends()):
    query = """
        update
            file_nifti_defacing
        set
            to_nifti_file = $2,
            three_d_rendered_face = $3,
            three_d_rendered_face_box = $4,
            three_d_rendered_defaced = $5,
            error_code = $6,
            success = true,
            completed_time = now()
        where
            file_nifti_defacing_id = $1
    """
    await db.fetch_one(
        query,
        [
            defacing_id,
            error_files.nifti_file_id,
            error_files.three_d_rendered_face,
            error_files.three_d_rendered_face_box,
            error_files.three_d_rendered_defaced,
            error_files.error_code,
        ]
    )

    return {
        "status": "success",
    }

@router.post("/{defacing_id}/error")
async def set_work_status_errored(request: Request, error_files: ErrorFiles, defacing_id: int, db: Database = Depends()):
    query = """
        update
            file_nifti_defacing
        set
            to_nifti_file = $2,
            three_d_rendered_face = $3,
            three_d_rendered_face_box = $4,
            three_d_rendered_defaced = $5,
            error_code = $6,
            success = false,
            completed_time = now()
        where
            file_nifti_defacing_id = $1
    """
    await db.fetch_one(
        query,
        [
            defacing_id,
            error_files.nifti_file_id,
            error_files.three_d_rendered_face,
            error_files.three_d_rendered_face_box,
            error_files.three_d_rendered_defaced,
            error_files.error_code,
        ]
    )

    return {
        "status": "success",
    }

