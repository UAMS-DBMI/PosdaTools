from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse
import asyncpg.exceptions

from .auth import logged_in_user, User
from ..util import Database

router = APIRouter(
    tags=["Functions for masking series"],
    dependencies=[logged_in_user]
)

class MaskerParameters(BaseModel):
    lr: int
    pa: int
    s: int
    i: int
    d: int

class ImportEventId(BaseModel):
    import_event_id: int


@router.get("/")
async def get_all_iecs():
    raise HTTPException(detail="not allowed", status_code=401)

@router.post("/{iec}/mask")
async def request_for_masking(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    """Flag for masking

    Creates a new entry in `masking` for this IEC.
    """

    try:
        record = await db.fetch_one("""\
            insert into masking
            (image_equivalence_class_id)
            values
            ($1)
            returning masking.*
        """, [iec])

        await db.fetch("""\
            insert into masking_history
            values
            ($1, $2, now(), $3)
        """, [iec, 'created', current_user.user_id])

        return record
    except asyncpg.exceptions.UniqueViolationError as e:
        raise HTTPException(detail='Already exists', status_code=409)
    except asyncpg.exceptions.ForeignKeyViolationError as e:
        raise HTTPException(detail="Invalid IEC supplied", status_code=422)


@router.get("/{iec}")
async def get_masking_details(iec: int, db: Database = Depends()):
    query = """
        select *
        from masking
        where image_equivalence_class_id = $1
    """

    for item in await db.fetch(query, [iec]):
        return item


@router.post("/{iec}/parameters")
async def update_masking_parameters(
    iec: int,
    item: MaskerParameters,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    """Update/Set masking parameters

    """

    json_str = item.model_dump_json()
    
    new_status = 'ready-to-process'

    try:
        await db.fetch("""\
            update masking
            set masking_parameters = $1,
                masking_status = $2
            where image_equivalence_class_id = $3
        """, [json_str, new_status, iec])

        await db.fetch("""\
            insert into masking_history
            values
            ($1, $2, now(), $3)
        """, [iec, new_status, current_user.user_id])

        return item
    except asyncpg.exceptions.ForeignKeyViolationError as e:
        raise HTTPException(detail="Invalid IEC supplied", status_code=422)


@router.post("/{iec}/complete")
async def mark_processing_complete(
    iec: int,
    item: ImportEventId,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    """Mark as process-complete

    This should not be called by users.
    The new ID needs to be submitted in the body as json, as
    { import_event_id: x }
    """

    # TODO: perhaps expand ImportEventId to include return_code,
    # and if that return_code is not success, set to failed ? 

    # TODO: should only be called by the system, so should we hardcode
    # a check for user_id of 0 here?

    new_status = 'process-complete'

    try:
        await db.fetch("""\
            update masking
            set import_event_id = $1,
                masking_status = $2
            where image_equivalence_class_id = $3
        """, [item.import_event_id, new_status, iec])

        await db.fetch("""\
            insert into masking_history
            values
            ($1, $2, now(), $3)
        """, [iec, new_status, current_user.user_id])

        return item
    except asyncpg.exceptions.ForeignKeyViolationError as e:
        raise HTTPException(detail="Invalid IEC supplied", status_code=422)

@router.post("/{iec}/accept")
async def mark_accept(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    """
    """

    new_status = 'accepted'

    try:
        await db.fetch("""\
            update masking
            set masking_status = $1
            where image_equivalence_class_id = $2
        """, [new_status, iec])

        await db.fetch("""\
            insert into masking_history
            values
            ($1, $2, now(), $3)
        """, [iec, new_status, current_user.user_id])

    except asyncpg.exceptions.ForeignKeyViolationError as e:
        raise HTTPException(detail="Invalid IEC supplied", status_code=422)

@router.post("/{iec}/reject")
async def mark_reject(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    """
    """

    new_status = 'rejected'

    try:
        await db.fetch("""\
            update masking
            set masking_status = $1
            where image_equivalence_class_id = $2
        """, [new_status, iec])

        await db.fetch("""\
            insert into masking_history
            values
            ($1, $2, now(), $3)
        """, [iec, new_status, current_user.user_id])

    except asyncpg.exceptions.ForeignKeyViolationError as e:
        raise HTTPException(detail="Invalid IEC supplied", status_code=422)

@router.post("/visualreview/{visual_review_instance_id}")
async def get_for_visualreview(
    visual_review_instance_id: int,
    db: Database = Depends(),
    current_user: User = logged_in_user):
    """Return list of all IECs in this VR that are flagged for Masking
    """

    try:
        records = await db.fetch("""\
            select
                image_equivalence_class_id
            from
                image_equivalence_class
                natural join masking
            where
                visual_review_instance_id = $1
        """, [visual_review_instance_id])

        return [x[0] for x in records]

    except:
        pass
