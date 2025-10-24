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
async def get_vr_iecs(vr: int, db: Database = Depends()) -> List[int]:
    """
    Get the list of IECs contained in this VR

    Results are always in ascending order.
    """
    query = """
        select
            image_equivalence_class_id
        from
            image_equivalence_class
        where
            visual_review_instance_id = $1
        order by 1
    """

    return [x[0] for x in await db.fetch(query, [vr])]

class ProcessingStatusEntry(BaseModel):
    count: int
    processing_status: Optional[str]
class ReviewStatusEntry(BaseModel):
    count: int
    review_status: Optional[str]
class DicomFileTypeEntry(BaseModel):
    count: int
    dicom_file_type: Optional[str]

class ValuesResponse(BaseModel):
    dicom_file_types: List[DicomFileTypeEntry] 
    review_statuses: List[ReviewStatusEntry]
    processing_statuses: List[ProcessingStatusEntry]

@router.get(
    "/{vr}/values",
    responses={
        404: { 'description': "invalid visual review id" },
    })
async def get_vr_extra_details(vr: int, db: Database = Depends()) -> ValuesResponse:
    """
    Get list of valid values for use in filtering, for the given VR.

    Returns the valid values for: review_status, processing_status, and 
    dicom_file_type
    """

    dicom_file_type_query = """\
        with iecs as (
            select image_equivalence_class_id, review_status, processing_status
            from image_equivalence_class
            where visual_review_instance_id = $1
        )
        select
            (
                select dicom_file_type
                from image_equivalence_class_input_image
                natural join dicom_file
                where image_equivalence_class_input_image.image_equivalence_class_id = iecs.image_equivalence_class_id
                limit 1
            ),
            count(*)
        from iecs
        group by 1
    """

    review_status_query = """\
        with iecs as (
            select image_equivalence_class_id, review_status, processing_status
            from image_equivalence_class
            where visual_review_instance_id = $1
        )
        select
            review_status,
            count(*) as count
        from iecs
        group by 1
    """

    processing_status_query = """\
        with iecs as (
            select image_equivalence_class_id, review_status, processing_status
            from image_equivalence_class
            where visual_review_instance_id = $1
        )
        select
            processing_status,
            count(*) as count
        from iecs
        group by 1
    """


    dicom_file_types = [dict(x) for x in await db.fetch(dicom_file_type_query, [vr])]
    review_statuses = [dict(x) for x in await db.fetch(review_status_query, [vr])]
    processing_statuses = [dict(x) for x in await db.fetch(processing_status_query, [vr])]

    if len(dicom_file_types) == 0 and len(review_statuses) == 0 and len(processing_statuses) == 0:
        test_results = await db.fetch("""\
            select visual_review_instance_id
            from visual_review_instance
            where visual_review_instance_id = $1
        """, (vr,))

        if len(test_results) == 0:
            raise HTTPException(detail="invalid visual review id", status_code=404)

    return {
        'dicom_file_types': dicom_file_types,
        'review_statuses': review_statuses,
        'processing_statuses': processing_statuses,
    }


class VRFilterParameters(BaseModel):
    dicom_file_type: Optional[str] = '*'
    processing_status: Optional[str] = '*'
    review_status: Optional[str] = '*'

@router.post(
    "/{vr}/filter",
    responses={
        404: { 'description': "invalid visual review id" },
    })
async def get_vr_filtered(vr: int, params: Optional[VRFilterParameters] = None, db: Database = Depends()) -> List[int]:
    """
    Return a filtered list of IECs in this VR. Use * for wildcard.
    The body is completely optional. If omitted, all IECs are returned.

    Results are always in ascending order.
    """
    query = """\
        with iecs as (
            select
            image_equivalence_class_id,
            review_status,
            processing_status,
                (
                    /*
                            All files in an IEC must always be of the same dicom_file_type,
                            so we can just select the first one here for speed
                    */
                    select dicom_file_type
                    from image_equivalence_class_input_image
                    natural join dicom_file
                    where image_equivalence_class_input_image.image_equivalence_class_id =
                            image_equivalence_class.image_equivalence_class_id
                    limit 1
                ) dicom_file_type
            from image_equivalence_class
            where visual_review_instance_id = $1
        )

        select image_equivalence_class_id
        from iecs
        where 1 = 1

    """

    bind_vars = [vr]
    bind_count = 1

    if params is not None:
        if params.dicom_file_type != '*':
            bind_count += 1
            query += f"and dicom_file_type = ${bind_count}\n"
            bind_vars.append(params.dicom_file_type)

        if params.processing_status != '*':
            bind_count += 1
            query += f"and processing_status = ${bind_count}\n"
            bind_vars.append(params.processing_status)

        if params.review_status != '*':
            bind_count += 1
            query += f"and review_status = ${bind_count}\n"
            bind_vars.append(params.review_status)

    query += "order by 1"

    results = await db.fetch(query, bind_vars)

    # If no results at all are returned, do a second check to see if 
    # the reason is because the VR was invalid.
    if len(results) == 0:
        test_results = await db.fetch("""\
            select visual_review_instance_id
            from visual_review_instance
            where visual_review_instance_id = $1
        """, (vr,))

        if len(test_results) == 0:
            raise HTTPException(detail="invalid visual review id", status_code=404)

    # flatten the results (we just want a list of iecs returned)
    return [x[0] for x in results]
