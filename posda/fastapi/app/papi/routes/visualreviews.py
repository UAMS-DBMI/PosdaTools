"""
Endpoints for working with Visual Review instances
"""
from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse

from .auth import logged_in_user, User
from ..util import Database

from ..util.models import File, FrameResponse, consistent

import numpy as np
from dataclasses import dataclass, asdict
from collections import defaultdict
from typing import Optional



router = APIRouter(
    tags=["Visual Review Instances"],
    dependencies=[logged_in_user]
)

@router.get("/")
async def get_all_iecs(request, **kwargs):
    return HTTPException(detail="listing all VRs is not allowed", status_code=401)

@router.get("/{vr}")
async def get_vr_details(vr: int, db: Database = Depends()):
    """
    Get details about a specific Visual Review (VR)
    """
    query = """
        select *
        from visual_review_instance
        where visual_review_instance_id = $1
    """

    return await db.fetch(query, [vr])

@router.get("/{vr}/iecs")
async def get_vr_iecs(vr: int, db: Database = Depends()):
    query = """
        select
            image_equivalence_class_id
        from
            image_equivalence_class
        where
            visual_review_instance_id = $1
    """

    return [x[0] for x in await db.fetch(query, [vr])]
