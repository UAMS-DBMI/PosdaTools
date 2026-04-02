from fastapi import Depends, APIRouter, HTTPException, Query
from typing import Optional
from pydantic import BaseModel
from datetime import datetime
import asyncpg
from .auth import logged_in_user, User

from ..util import Database

router = APIRouter(
    tags=["distribution"],
    dependencies=[logged_in_user]
)

# --- Models ---

class DatasetInsert(BaseModel):
    dataset_type: str
    dataset_title: str
    dataset_name: str
    dataset_short_title: str
    dataset_doi: str
    active: bool = True

class DatasetUpdate(BaseModel):
    dataset_type: Optional[str] = None
    dataset_title: Optional[str] = None
    dataset_name: Optional[str] = None
    dataset_short_title: Optional[str] = None
    dataset_doi: Optional[str] = None
    active: Optional[bool] = None

class DatasetReleaseInsert(BaseModel):
    release_number: int
    release_date: datetime
    release_notes: str

class DatasetReleaseUpdate(BaseModel):
    dataset_id: Optional[int] = None
    release_number: Optional[int] = None
    release_date: Optional[datetime] = None
    release_notes: Optional[str] = None

class DatasetReleaseRecordsetRequest(BaseModel):
    recordset_release_ids: list[int]

class DatasetReleaseTransferInsert(BaseModel):
    destination_id: int
    transfer_name: str
    transfer_mode: str
    transfer_notes:  Optional[str] = None
    transfer_status: Optional[str] = "draft"

class RecordsetUpdate(BaseModel):
    recordset_title: Optional[str] = None
    recordset_name: Optional[str] = None
    recordset_type: Optional[str] = None

class RecordsetCreate(BaseModel):
    recordset_doi: str
    dataset_id: int
    license_id: int
    recordset_type: str
    recordset_title: str
    recordset_name: str
    active: bool = True


def item_response(data):
    return {"data": data}


def list_response(rows):
    return {"data": rows, "meta": {"count": len(rows)}}


def api_error(
        code: str, 
        message: str, 
        details: Optional[dict] = None, 
        status_code: int = 400):
    
    raise HTTPException(
        status_code=status_code,
        detail={
            "error": {
                "code": code,
                "message": message,
                "details": details or {},
            }
        },
    )


def db_error(
    e: Exception,
    *,
    operation: str,
    context: Optional[dict] = None):
    
    details = {"exception": type(e).__name__, "message": str(e), **(context or {})}

    if isinstance(e, asyncpg.exceptions.UniqueViolationError):
        api_error("CONFLICT", "Unique constraint violation", details, 409)

    if isinstance(e, asyncpg.exceptions.ForeignKeyViolationError):
        api_error("VALIDATION_ERROR", "Invalid foreign key reference", details, 422)

    api_error("INTERNAL_ERROR", f"Error {operation}", details, 500)


# -----------------------------------------DATASETS------------------------------------------------

@router.get("/datasets")
# List datasets
async def get_datasets(
    search: Optional[str] = Query(default=None),
    active_only: Optional[bool] = Query(default=None),
    type: Optional[str] = Query(default=None),
    db: Database = Depends()):
    
    where_clauses = []
    values = []
    idx = 1

    if search:
        where_clauses.append(
            f"""(
                dataset_title ilike ${idx}
                or dataset_name ilike ${idx}
                or dataset_short_title ilike ${idx}
                or dataset_doi ilike ${idx}
            )"""
        )
        values.append(f"%{search}%")
        idx += 1

    if active_only is True:
        where_clauses.append("active = true")

    if type:
        where_clauses.append(f"dataset_type = ${idx}")
        values.append(type)
        idx += 1

    where_sql = f"where {' and '.join(where_clauses)}" if where_clauses else ""

    query = f"""\
        select
            dataset_id,
            dataset_type,
            dataset_title,
            dataset_name,
            dataset_short_title,
            dataset_doi,
            active,
            when_created,
            when_updated
        from
            dataset
        {where_sql}
        order by dataset_id
        """

    try:
        rows = await db.fetch(query, values)
    except Exception as e:
        db_error(e, operation="fetching datasets")

    return list_response(rows)


@router.post("/datasets")
# Create dataset
async def create_dataset(
    payload: DatasetInsert,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    if not payload.dataset_type.strip() or not payload.dataset_title.strip() or not payload.dataset_name.strip() or not payload.dataset_short_title.strip() or not payload.dataset_doi.strip():
        api_error(
            "VALIDATION_ERROR",
            "Required dataset fields must be non-empty",
            {
                "required": [
                    "dataset_type",
                    "dataset_title",
                    "dataset_name",
                    "dataset_short_title",
                    "dataset_doi",
                ]
            },
            422,
        )

    query = """\
        insert into dataset (
            dataset_type,
            dataset_title,
            dataset_name,
            dataset_short_title,
            dataset_doi,
            active,
            when_created,
            when_updated,
            who_created,
            who_updated
        )
        values ($1, $2, $3, $4, $5, $6, now(), now(), $7, $7)
        returning
            dataset_id,
            dataset_type,
            dataset_title,
            dataset_name,
            dataset_short_title,
            dataset_doi,
            active,
            when_created,
            when_updated
        """

    values = [
        payload.dataset_type,
        payload.dataset_title,
        payload.dataset_name,
        payload.dataset_short_title,
        payload.dataset_doi,
        payload.active,
        current_user.username,
    ]

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(e, operation="creating dataset")

    return item_response(record[0])


@router.get("/datasets/{dataset_id}")
# Get dataset detail
async def get_dataset_by_id(dataset_id: int, db: Database = Depends()):
    query = """\
        select
            dataset_id,
            dataset_type,
            dataset_title,
            dataset_name,
            dataset_short_title,
            dataset_doi,
            active,
            when_created,
            when_updated
        from
            dataset
        where
            dataset_id = $1
        """

    try:
        record = await db.fetch(query, [dataset_id])
    except Exception as e:
        db_error(e, operation="fetching dataset", context={"dataset_id": dataset_id})

    if not record:
        api_error("NOT_FOUND", "Dataset not found", {"dataset_id": dataset_id}, 404)
    return item_response(record[0])


@router.put("/datasets/{dataset_id}")
# Update dataset metadata
async def update_dataset(
    dataset_id: int,
    payload: DatasetUpdate,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    field_values = []

    def add_text_field(column_name: str, value: Optional[str]):
        if value is None:
            return

        if not value.strip():
            api_error("VALIDATION_ERROR", f"{column_name} must be non-empty", {"field": column_name}, 422)

        field_values.append((column_name, value))

    add_text_field("dataset_type", payload.dataset_type)
    add_text_field("dataset_title", payload.dataset_title)
    add_text_field("dataset_name", payload.dataset_name)
    add_text_field("dataset_short_title", payload.dataset_short_title)
    add_text_field("dataset_doi", payload.dataset_doi)

    if payload.active is not None:
        field_values.append(("active", payload.active))

    if not field_values:
        api_error("VALIDATION_ERROR", "No dataset fields were provided", {}, 422)

    values = [value for _, value in field_values]
    updates = [f"{column_name} = ${index}" for index, (column_name, _) in enumerate(field_values, start=1)]
    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${len(values) + 1}")
    values.append(current_user.username)

    dataset_id_placeholder = len(values) + 1

    query = f"""\
        update dataset
        set {', '.join(updates)}
        where dataset_id = ${dataset_id_placeholder}
        returning
            dataset_id,
            dataset_type,
            dataset_title,
            dataset_name,
            dataset_short_title,
            dataset_doi,
            active,
            when_created,
            when_updated
        """

    values.append(dataset_id)

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(e, operation="updating dataset", context={"dataset_id": dataset_id})

    if not record:
        api_error("NOT_FOUND", "Dataset not found", {"dataset_id": dataset_id}, 404)

    return item_response(record[0])


@router.get("/datasets/{dataset_id}/recordsets")
# List recordsets by dataset
async def get_recordsets_by_dataset(
    dataset_id: int,
    active_only: Optional[bool] = Query(default=None),
    db: Database = Depends()):

    query = """\
        select
            rs.recordset_id,
            rs.recordset_doi,
            rs.recordset_title,
            rs.recordset_type,
            rsl.license_id,
            rsl.license_label,
            rsl.license_url,
            rsl.is_public_access,
            rs.active
        from
            dataset 
            join recordset rs using (dataset_id)
            join recordset_license rsl using (license_id)
        where
            dataset_id = $1
        """

    if active_only is True:
        query += "\n and rs.active"

    try:
        records = await db.fetch(query, [dataset_id])
    except Exception as e:
        db_error(e, operation="fetching recordsets for dataset", context={"dataset_id": dataset_id})

    return list_response(records)


@router.get("/datasets/{dataset_id}/releases")
# List dataset releases by dataset
async def get_releases_by_dataset(
    dataset_id: int,
    latest_only: Optional[bool] = Query(default=None),
    db: Database = Depends()):

    query = """\
        select
            dr.dataset_release_id,
            d.dataset_id,
            dr.release_number,
            dr.release_date,
            dr.release_notes
        from
            dataset d
            natural join dataset_release dr
        where
            d.dataset_id = $1
        order by
            dr.release_number desc
        """

    if latest_only is True:
        query += "\nlimit 1"

    try:
        records = await db.fetch(query, [dataset_id])
    except Exception as e:
        db_error(e, operation="fetching dataset releases", context={"dataset_id": dataset_id})

    return list_response(records)


@router.post("/datasets/{dataset_id}/releases")
# Create a new dataset release
async def create_dataset_release(
    dataset_id: int,
    payload: DatasetReleaseInsert,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    query = """\
        insert into dataset_release (dataset_id, release_number, release_date, release_notes, when_created, who_created, when_updated, who_updated)
        values ($1, $2, $3, $4, now(), $5, now(), $5)
        returning dataset_release_id, dataset_id, release_number, release_date, release_notes
    """
    values = [
        dataset_id,
        payload.release_number,
        payload.release_date,
        payload.release_notes,
        current_user.username,
    ]

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(e, operation="creating dataset release", context={"dataset_id": dataset_id})

    if not record:
        api_error("NOT_FOUND", "Dataset not found", {"dataset_id": dataset_id}, 404)

    return item_response(record[0])



# #Note added recordset_release_id as input
# #This structure implies the recordset_release record was inserted prior to this call
# #It also assumes that the PK and release number are auto-incrementing
# @router.post("/datasets/{dataset_id}/releases/{recordset_release_id}")
# async def add_release_to_dataset(dataset_id: int, recordset_release_id: int, db: Database = Depends()):
#     record = await db.fetch("""\
#         with new_release as (
#             insert into dataset_release (dataset_id, release_date)
#             values ($1, now())
#             returning dataset_release_id
#         )
#         insert into dataset_release_recordset (dataset_release_id, recordset_release_id)
#         select dataset_release_id, $2 from new_release
#     """, [dataset_id,recordset_release_id])
#     print(record)
#     if not record:
#         raise HTTPException(detail="Error updating edit status", status_code=422)
#     return {
#         'status': 'success',
#     }


# @router.get("/dataset-releases/{dataset_release_id}")
# async def get_dataset_release_details_by_id(dataset_release_id: int, db: Database = Depends()):
#     query = """\
#         select
#             cr.dataset_release_id,
#             cr.release_number,
#             cr.release_date,
#             crds.recordset_release_id
#         from
#             dataset_release cr
#             natural join dataset_release_recordset crds
#         where
#             cr.dataset_release_id = $1;
#         """
#     return await db.fetch(query, [dataset_release_id])

# -----------------------------------------DATASET RELEASES------------------------------------------------

@router.get("/datasets/releases/{release_id}")
# Get dataset release detail
async def get_dataset_release_by_id(release_id: int, db: Database = Depends()):
    query = """\
        select
            dr.dataset_release_id,
            dr.dataset_id,
            dr.release_number,
            dr.release_date,
            dr.release_notes,
            dr.when_created,
            dr.who_created,
            dr.when_updated,
            dr.who_updated
        from dataset_release dr
        where dr.dataset_release_id = $1
        """
    try:
        record = await db.fetch(query, [release_id])
    except Exception as e:
        db_error(e, operation="fetching dataset release", context={"release_id": release_id})

    if not record:
        api_error("NOT_FOUND", "Dataset release not found", {"release_id": release_id}, 404)

    return item_response(record[0])


@router.put("/datasets/releases/{release_id}")
# Update dataset release
async def update_dataset_release_by_id(
    release_id: int,
    payload: DatasetReleaseUpdate,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    field_values = []

    if payload.dataset_id is not None:
        field_values.append(("dataset_id", payload.dataset_id))

    if payload.release_number is not None:
        field_values.append(("release_number", payload.release_number))

    if payload.release_date is not None:
        field_values.append(("release_date", payload.release_date))

    if payload.release_notes is not None:
        field_values.append(("release_notes", payload.release_notes))

    if not field_values:
        api_error("VALIDATION_ERROR", "No dataset release fields were provided", {}, 422)

    values = [value for _, value in field_values]
    updates = [f"{column_name} = ${index}" for index, (column_name, _) in enumerate(field_values, start=1)]
    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${len(values) + 1}")
    values.append(current_user.username)

    release_id_placeholder = len(values) + 1

    query = f"""
        update dataset_release
        set {', '.join(updates)}
        where dataset_release_id = ${release_id_placeholder}
        returning
            dataset_release_id,
            dataset_id,
            release_number,
            release_date,
            release_notes,
            when_created,
            who_created,
            when_updated,
            who_updated
    """

    values.append(release_id)

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(e, operation="updating dataset release", context={"release_id": release_id})

    if not record:
        api_error("NOT_FOUND", "Dataset release not found", {"release_id": release_id}, 404)

    return item_response(record[0])


@router.get("/datasets/releases/{release_id}/recordsets")
# List recordset releases in a dataset release
async def get_recordsets_for_dataset_release_by_id(release_id: int, db: Database = Depends()):
    query = """\
        select
			rr.recordset_id,
            rr.recordset_release_id,
            rs.recordset_title,
            rr.release_number        
        from dataset_release dr
        join dataset_release_recordset drr using (dataset_release_id)
        join recordset_release rr using (recordset_release_id)
        join recordset rs using (recordset_id)
        where dr.dataset_release_id = $1        
        """
    try:
        records = await db.fetch(query, [release_id])
    except Exception as e:
        db_error(e, operation="fetching recordset releases for dataset release", context={"release_id": release_id})

    return list_response(records)


@router.post("/datasets/releases/{release_id}/recordsets:add")
# Add recordset releases to a dataset release
async def add_recordset_release_to_dataset_release_by_id(
    release_id: int,
    payload: DatasetReleaseRecordsetRequest,
    db: Database = Depends()):
    
    insert_query = """
            insert into dataset_release_recordset
            (dataset_release_id, recordset_release_id)
            values ($1, $2)
            returning recordset_release_id
        """
    count_query = """
            select count(*) as current_count
            from dataset_release_recordset
            where dataset_release_id = $1
        """

    recordset_release_ids = payload.recordset_release_ids

    if not recordset_release_ids:
        api_error(
            "VALIDATION_ERROR",
            "No records to insert",
            {"recordset_release_ids": []},
            422,
        )

    added_recordset_release_ids = []

    try:
        for recordset_release_id in recordset_release_ids:
            record = await db.fetch(insert_query, [release_id, recordset_release_id])
            if record:
                added_recordset_release_ids.append(record[0]["recordset_release_id"])

        count_record = await db.fetch(count_query, [release_id])
    except Exception as e:
        db_error(
            e,
            operation="adding recordset releases to dataset release",
            context={"release_id": release_id},
        )

    return item_response(
        {
            "dataset_release_id": release_id,
            "added_recordset_release_ids": added_recordset_release_ids,
            "current_count": count_record[0]["current_count"] if count_record else 0,
        }
    )


@router.post("/datasets/releases/{release_id}/recordsets:remove")
# Remove recordset releases from a dataset release
async def remove_recordset_release_from_dataset_release_by_id(
    release_id: int,
    payload: DatasetReleaseRecordsetRequest,
    db: Database = Depends()):

    delete_query = """
            delete from dataset_release_recordset
            where dataset_release_id = $1 and recordset_release_id = $2
            returning recordset_release_id
        """
    count_query = """
            select count(*) as current_count
            from dataset_release_recordset
            where dataset_release_id = $1
        """

    recordset_release_ids = payload.recordset_release_ids

    if not recordset_release_ids:
        api_error(
            "VALIDATION_ERROR",
            "No records to remove",
            {"recordset_release_ids": []},
            422,
        )

    removed_recordset_release_ids = []

    try:
        for recordset_release_id in recordset_release_ids:
            record = await db.fetch(delete_query, [release_id, recordset_release_id])
            if record:
                removed_recordset_release_ids.append(record[0]["recordset_release_id"])

        count_record = await db.fetch(count_query, [release_id])
    except Exception as e:
        db_error(
            e,
            operation="removing recordset releases from dataset release",
            context={"release_id": release_id},
        )

    return item_response(
        {
            "dataset_release_id": release_id,
            "removed_recordset_release_ids": removed_recordset_release_ids,
            "current_count": count_record[0]["current_count"] if count_record else 0,
        }
    )


@router.get("/datasets/releases/{release_id}/transfers")
# List transfers for a dataset release
async def get_transfers_for_dataset_release_by_id(release_id: int, db: Database = Depends()):
    query = """\
        select
            drt.dataset_release_transfer_id,
            drt.destination_id,
            td.destination_name,
            td.destination_abbr,
            drt.transfer_name,
            drt.transfer_mode,
            drt.transfer_status,
            drt.transfer_notes
        from dataset_release_transfer drt
        join transfer_destination td using (destination_id)
        where drt.dataset_release_id = $1;
        """
    try:
        records = await db.fetch(query, [release_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching dataset release transfers",
            context={"release_id": release_id},
        )

    return list_response(records)


@router.post("/datasets/releases/{release_id}/transfers")
# Create transfer for a dataset release
async def create_transfer_for__dataset_release_by_id(release_id: int,payload: DatasetReleaseTransferInsert,  db: Database = Depends()):
    if payload.destination_id <= 0 or not payload.transfer_name.strip() or not payload.transfer_mode.strip():
        api_error(
            "VALIDATION_ERROR",
            "Required transfer fields must be non-empty",
            {"required": ["destination_id", "transfer_name", "transfer_mode"]},
            422,
        )

    query = """\
        with inserted as (
            insert into dataset_release_transfer
            (
                dataset_release_id,
                destination_id,
                transfer_name,
                transfer_mode,
                transfer_status,
                transfer_notes
            )
            values ($1, $2, $3, $4, $5, $6)
            returning
                dataset_release_transfer_id,
                destination_id,
                transfer_name,
                transfer_mode,
                transfer_status,
                transfer_notes
        )
        select
            i.dataset_release_transfer_id,
            i.destination_id,
            td.destination_name,
            td.destination_abbr,
            i.transfer_name,
            i.transfer_mode,
            i.transfer_status,
            i.transfer_notes
        from inserted i
        join transfer_destination td using (destination_id)
        """

    values = [
        release_id,
        payload.destination_id,
        payload.transfer_name,
        payload.transfer_mode,
        payload.transfer_status,
        payload.transfer_notes,
    ]

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(
            e,
            operation="creating dataset release transfer",
            context={"release_id": release_id, "destination_id": payload.destination_id},
        )

    return item_response(record[0])



# -----------------------------------------RECORDSETS------------------------------------------------

@router.get("/recordsets")
# List recordsets
async def get_recordsets(
    dataset_id: Optional[int] = Query(default=None),
    search: Optional[str] = Query(default=None),
    active_only: Optional[bool] = Query(default=None),
    db: Database = Depends()):

    where_clauses = []
    values = []
    idx = 1

    if dataset_id is not None:
        where_clauses.append(f"r.dataset_id = ${idx}")
        values.append(dataset_id)
        idx += 1

    if search:
        where_clauses.append(
            f"""(
                r.recordset_title ilike ${idx}
                or r.recordset_name ilike ${idx}
                or r.recordset_doi ilike ${idx}
            )"""
        )
        values.append(f"%{search}%")
        idx += 1

    if active_only is True:
        where_clauses.append("r.active = true")

    where_sql = f"where {' and '.join(where_clauses)}" if where_clauses else ""

    query = f"""\
        select
            r.recordset_id,
            r.recordset_doi,
            r.dataset_id,
            r.license_id,            
            r.recordset_type,
            r.recordset_title,
            r.recordset_name,
            r.active
        from
            recordset r
        {where_sql}
        order by r.recordset_id
        """

    try:
        records = await db.fetch(query, values)
    except Exception as e:
        db_error(e, operation="fetching recordsets")

    return list_response(records)


@router.post("/recordsets")
# Create recordset
async def create_recordset(
    payload: RecordsetCreate,
    current_user: User = logged_in_user,
    db: Database = Depends(),
):
    if (
        not payload.recordset_doi.strip()
        or not payload.recordset_type.strip()
        or not payload.recordset_title.strip()
        or not payload.recordset_name.strip()
    ):
        api_error(
            "VALIDATION_ERROR",
            "Required recordset fields must be non-empty",
            {
                "required": [
                    "recordset_doi",
                    "recordset_type",
                    "recordset_title",
                    "recordset_name",
                ]
            },
            422,
        )

    query = """\
        insert into recordset (
            recordset_doi,
            dataset_id,
            license_id,
            recordset_type,
            recordset_title,
            recordset_name,
            active,
            when_created,
            when_updated,
            who_created,
            who_updated
        )
        values ($1, $2, $3, $4, $5, $6, $7, now(), now(), $8, $8)
        returning
            recordset_id,
            recordset_doi,
            dataset_id,
            license_id,
            recordset_type,
            recordset_title,
            recordset_name,
            active,
            when_created,
            when_updated
        """

    values = [
        payload.recordset_doi,
        payload.dataset_id,
        payload.license_id,
        payload.recordset_type,
        payload.recordset_title,
        payload.recordset_name,
        payload.active,
        current_user.username,
    ]

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(
            e,
            operation="creating recordset",
        )

    return item_response(record[0])


@router.get("/recordsets/{recordset_id}")
# Get recordset detail
async def get_recordset_by_id(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_id,
            r.recordset_doi,
            r.dataset_id,
            r.recordset_type,
            r.recordset_title,
            r.recordset_name,
            r.active,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated,
            rl.license_id,
            rl.license_label,
            rl.license_url,
            rl.is_public_access
        from
            recordset r
            join recordset_license rl using (license_id)
        where
            r.recordset_id = $1;
        """
    try:
        record = await db.fetch(query, [recordset_id])
    except Exception as e:
        db_error(e, operation="fetching recordset", context={"recordset_id": recordset_id})

    if not record:
        api_error("NOT_FOUND", "Recordset not found", {"recordset_id": recordset_id}, 404)

    return item_response(record[0])








#Purpose: Create recordset
@router.post("/recordsets/{dataset_id}/")
async def create_recordset(dataset_id: int, db: Database = Depends()):
    record = await db.fetch("""\
            insert into recordset (dataset_id, when_created)
            values ($1, now())
            returning recordset_id
    """, [dataset_id])

    if not record:
        raise HTTPException(detail="Error updating edit status", status_code=422)
    return {'status': 'success'}


# #Purpose: Update recordset metadata
@router.put("/recordsets/{recordset_id}")
async def update_recordset(recordset_id: int, payload: RecordsetUpdate, db: Database = Depends()):
    updates = []
    values = []
    idx = 1

    if payload.recordset_title is not None:
        updates.append(f"recordset_title = ${idx}")
        values.append(payload.recordset_title)
        idx += 1

    if payload.recordset_name is not None:
        updates.append(f"recordset_name = ${idx}")
        values.append(payload.recordset_name)
        idx += 1

    if payload.recordset_type is not None:
        updates.append(f"recordset_type = ${idx}")
        values.append(payload.recordset_type)
        idx += 1

    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")

    query = f"""
        update recordset
        set {", ".join(updates)}
        where recordset_id = ${idx}
        returning *
    """

    values.append(recordset_id)

    record = await db.fetch(query, values)

    if not record:
        raise HTTPException(detail="Error updating edit status", status_code=422)

    return {'status': 'success'}


# Purpose: List immutable releases for a recordset
@router.get("/recordsets/{recordset_id}/releases")
async def get_recordset_releases_by_id(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_release_id,
            r.recordset_id,
            r.release_number,
            r.release_date,
            r.release_notes,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated
        from
            recordset_release r
        where
            r.recordset_id = $1;
        """
    return await db.fetch(query,[recordset_id])


# Purpose: List draft releases for a recordset
@router.get("/recordsets/{recordset_id}/drafts")
async def get_recordset_drafts_by_id(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_draft_id,
            r.recordset_id,
            r.cloned_from_release_id,
            r.draft_name,
            r.draft_status,
            r.draft_notes,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated
        from
            recordset_draft r
        where
            r.recordset_id = $1;
        """
    return await db.fetch(query, [recordset_id])


# Purpose: Get latest immutable release
@router.get("/recordsets/{recordset_id}/latest-release")
async def get_recordset_latest_release_by_id(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_release_id,
            r.recordset_id,
            r.release_number,
            r.release_date,
            r.release_notes,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated
        from
            recordset_release r
        where
            r.recordset_id = $1
        order by r.release_number desc
        limit 1;
        """
    return await db.fetch(query, [recordset_id])


#Unclear on the use of available files, so starting with a draft and release version


# Purpose: List candidate files available for inclusion (draft)
@router.get("/recordsets/{recordset_draft_id}/available-draft-files")
async def get_recordset_available_draft_files(recordset_draft_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_draft_id,
            r.file_id
        from
            recordset_draft_file r
        where
            r.recordset_draft_id = $1;
        """
    return await db.fetch(query,[recordset_draft_id])


# Purpose: List candidate files available for inclusion (release)
@router.get("/recordsets/{recordset_release_id}/available-release-files")
async def get_recordset_available_release_files(recordset_release_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_release_id,
            r.file_id
        from
            recordset_release_file r
        where
            r.recordset_release_id = $1;
        """
    return await db.fetch(query,[recordset_release_id])



