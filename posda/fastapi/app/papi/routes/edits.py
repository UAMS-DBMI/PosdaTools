from fastapi import Depends, APIRouter, HTTPException, Form, Request
from fastapi import Response, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Union
from enum import Enum

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database

import json

# An example of how to easily restrict the allowed states
# just set them here and then change the types below to State
# class State(str, Enum):
#     statea = "statea"
#     stateb = "stateb"
#     statec = "statec"


class StateChangeRequest(BaseModel):
    edit_id: int
    expected_state: str
    new_state: str

    table_name: str = "dicom_edit_compare_disposition"
    column_name: str = "current_disposition"


@router.post("/state")
async def set_state(
    scr: StateChangeRequest,
    db: Database = Depends()
):
    """Modify the state of an edit

    TODO: This really needs to require authentication!
    """

    query = f"""
        update {scr.table_name}
        set {scr.column_name} = $1
        where subprocess_invocation_id = $2
        and {scr.column_name} = $3
        returning subprocess_invocation_id
    """

    results = await db.fetch(query, [
        scr.new_state,
        scr.edit_id,
        scr.expected_state
    ])

    if len(results) <= 0:

        query = f"""
            select {scr.column_name}
            from {scr.table_name}
            where subprocess_invocation_id = $1
        """

        results = await db.fetch(query, [scr.edit_id])
        if len(results) <= 0:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND
            )

        result = results[0]

        return JSONResponse(
            content={
                "detail": "Column was not in expected state",
                "expected_state": scr.expected_state,
                "actual_state": list(dict(result).values())[0]
            },
            status_code=status.HTTP_409_CONFLICT
        )

    return Response(status_code=status.HTTP_200_OK)
