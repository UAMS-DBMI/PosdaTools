from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import datetime
from starlette.responses import Response, FileResponse
import asyncpg.exceptions

from .auth import logged_in_user, User
from ..util import Database

from ..util.models import File, FrameResponse, consistent

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

@router.post("/abortwork")
async def get_work_for_masker(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """Reset an IEC back to ready-to-process

    Used only when Nopperabo is shutdown while working.
    If the IEC is not in in-process status, nothing is done.
    """

    query = """
        update masking
        set masking_status = 'ready-to-process'
        where image_equivalence_class_id = $1
          and masking_status = 'in-process'
    """

    await db.fetch(query, [iec])


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
        with input_image as (
            select distinct image_equivalence_class_id, site_id
            from masking
            natural join image_equivalence_class_input_image
            natural join ctp_file
        ), uid_root as (
            select input_image.*, uid_root
            from input_image
            join submissions on submissions.site_code || submissions.collection_code = input_image.site_id
        )

        select *
        from masking
        natural left join uid_root
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

@router.post("/{iec}/skip")
async def mark_accept(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """
    """

    new_status = 'skipped'

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


@router.post("/{iec}/nonmaskable")
async def mark_accept(
    iec: int,
    db: Database = Depends(),
    current_user: User = logged_in_user
):
    """
    """

    new_status = 'nonmaskable'

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

    query = """
        select
            file_id,
            image_type,
            coalesce(number_of_frames, 1) as frame_count,
            iop,
            ipp
        from
            masking
            natural join file_import
            natural left join file_image
            natural left join image
            natural left join file_image_geometry
            natural left join image_geometry
        where
            image_equivalence_class_id = $1
    """

    def raw_to_obj(rows):
        return [File.from_raw(i) for i in rows]

    framelist = raw_to_obj([list(x) for x in await db.fetch(query, [iec])])
    if len(framelist) < 1:
        raise HTTPException(detail="no records returned", status_code=404)

    sorted_framelist, consistent_frames = consistent(framelist)

    simplified = [
        { 
            "file_id": x.file_id,
            "num_of_frames": x.frame_count,
        }
        for x in sorted_framelist
    ]

    return {
        "volumetric": consistent_frames,
        "frames": simplified,
    }

