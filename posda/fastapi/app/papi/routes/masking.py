from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
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
    LR: int
    PA: int
    IS: int
    width: int
    height: int
    depth: int
    form: Optional[str] = 'cylinder'
    function: Optional[str] = 'mask'

class CompleteParams(BaseModel):
    import_event_id: int
    exit_code: int


@router.get("/")
async def get_all_iecs(
    Database = Depends(),
    current_user: User = logged_in_user
):
    raise HTTPException(detail="not allowed", status_code=401)

@router.get("/getwork")
async def get_work_for_masker(
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """Get work for the worker program
    """

    query = """
        update masking
        set masking_status = 'in-process'
        where image_equivalence_class_id = (
            select image_equivalence_class_id
            from masking
            where masking_status = 'ready-to-process'
            limit 1
            for update skip locked
        )
        returning image_equivalence_class_id
    """

    for item in await db.fetch(query):
        return item

    raise HTTPException(status_code=404)


@router.post("/{iec}/mask")
async def request_for_masking(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
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
    """Return details about the given masking item, including history
    """

    query = """
        select *
        from masking
        where image_equivalence_class_id = $1
    """

    item = dict(await db.fetch_one(query, [iec]))
    item['history'] = await db.fetch("""\
        select
            h.new_status,
            h.when_changed,
            u.user_name as who_changed
        from masking_history h
        join auth.users u on u.user_id = h.who_changed
        where image_equivalence_class_id = $1
    """, [iec])

    return item


@router.post("/{iec}/parameters")
async def update_masking_parameters(
    iec: int,
    item: MaskerParameters,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
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
    item: CompleteParams,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """Mark as process-complete

    This should not be called by users.
    The new ID needs to be submitted in the body as json, as
    { import_event_id: x, exit_code: 0 }
    """

    # TODO: should only be called by the system, so should we hardcode
    # a check for user_id of 0 here?

    new_status = 'process-complete'
    import_event_id = item.import_event_id

    if item.exit_code != 0:
        new_status = 'errored'
        import_event_id = None

    try:
        await db.fetch("""\
            update masking
            set import_event_id = $1,
                masking_exit_code = $2,
                masking_status = $3
            where image_equivalence_class_id = $4
        """, [import_event_id, item.exit_code, new_status, iec])

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
    current_user: User = logged_in_user
):
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
    current_user: User = logged_in_user
):
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

@router.get("/visualreview/{visual_review_instance_id}")
async def get_for_visualreview(
    visual_review_instance_id: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
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

@router.get("/{iec}/reviewfiles")
async def get_iec_review_files(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """Get list of completed files for review"""

    records = await db.fetch("""\
        select
            file_id
        from
            masking
            natural join file_import
            natural join file_sop_common
        where
            image_equivalence_class_id = $1
        order by
            -- sometimes instance_number is empty string or null
            case instance_number
                when '' then '0'
                when null then '0'
                else instance_number
            end::int
    """, [iec])

    return [x[0] for x in records]
