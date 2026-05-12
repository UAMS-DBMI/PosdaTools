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
    dataset_type_id: int
    dataset_name: str
    dataset_doi: str
    active: bool = True

class DatasetUpdate(BaseModel):
    dataset_type_id: Optional[int] = None
    dataset_name: Optional[str] = None
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
    transfer_mode_id: int
    transfer_notes:  Optional[str] = None
    transfer_status: Optional[str] = "draft"

class RecordsetUpdate(BaseModel):
    recordset_doi: Optional[str] = None
    dataset_id: Optional[int] = None
    license_id: Optional[int] = None
    recordset_name: Optional[str] = None
    recordset_type_id: Optional[int] = None
    active: Optional[bool] = None

class RecordsetCreate(BaseModel):
    recordset_doi: str
    dataset_id: int
    license_id: int
    recordset_type_id: int
    recordset_name: str
    active: bool = True

class DestinationUpdate(BaseModel):
    default_display: Optional[bool] = None
    default_transfer_mode_id: Optional[int] = None

class RecordsetDraftInsert(BaseModel):
    draft_name: str
    draft_status: Optional[str] = "open"
    draft_notes:  Optional[str] = None
    cloned_from_release_id: Optional[int] = None

class RecordsetDraftUpdate(BaseModel):
    recordset_id: Optional[int] = None
    draft_name: Optional[str] = None
    draft_notes:  Optional[str] = None
    draft_status: Optional[str] = "open"
    cloned_from_release_id: Optional[int] = None

class RecordsetDraftFileAdd(BaseModel):
    file_ids: list[int]

class RecordsetDraftFileRemove(BaseModel):
    file_ids: list[int]

class RecordsetReleaseInsert(BaseModel):
    release_number: int
    release_date: datetime
    release_notes: str

class DatasetReleaseTransferUpdate(BaseModel):
    transfer_name: Optional[str] = None
    transfer_mode_id: Optional[int] = None
    transfer_status: Optional[str] = None
    transfer_notes: Optional[str] = None

class TransferReleaseRecordsetRequest(BaseModel):
    recordset_release_ids: list[int]

# --- Responses ---

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

# -----------------------------------------LOOKUP TABLES------------------------------------------------

@router.get("/lookups/dataset-types")
# List dataset types
async def get_dataset_types(db: Database = Depends()):

    query = """
        select dataset_type_id, dataset_type_name 
        from dataset_type
    """

    try:
        records = await db.fetch(query)
    except Exception as e:
        db_error(e, operation="fetching dataset types")

    return list_response(records)

@router.get("/lookups/dataset-relation-types")
# List dataset relation types
async def get_dataset_relation_types(db: Database = Depends()):

    query = """
        select relation_type_id,
            forward_label || ' --> <-- ' || reverse_label as relation_type_label
        from dataset_relation_type;
    """

    try:
        records = await db.fetch(query)
    except Exception as e:
        db_error(e, operation="fetching dataset relation types")

    return list_response(records)

@router.get("/lookups/recordset-types")
# List recordset types
async def get_recordset_types(db: Database = Depends()):

    query = """
        select recordset_type_id, recordset_type_name 
        from recordset_type
    """

    try:
        records = await db.fetch(query)
    except Exception as e:
        db_error(e, operation="fetching recordset types")

    return list_response(records)

@router.get("/lookups/transfer-modes")
# List transfer modes
async def get_transfer_modes(db: Database = Depends()):

    query = """
        select transfer_mode_id, transfer_mode_name 
        from transfer_mode
    """

    try:
        records = await db.fetch(query)
    except Exception as e:
        db_error(e, operation="fetching transfer modes")

    return list_response(records)

@router.get("/lookups/licenses")
# List licenses
async def get_licenses(db: Database = Depends()):

    query = """
        select license_id, license_name, license_label, license_url, is_public_access
        from recordset_license
    """

    try:
        records = await db.fetch(query)
    except Exception as e:
        db_error(e, operation="fetching licenses")

    return list_response(records)

@router.get("/lookups/destinations")
# List destinations
async def get_destinations(db: Database = Depends()):
    query = """\
        select destination_id, destination_name, destination_abbr
        from transfer_destination;
        """
    try:
        records = await db.fetch(query)
    except Exception as e:
        db_error(e, operation="fetching destinations")

    return list_response(records)

# -----------------------------------------DATASETS------------------------------------------------

@router.get("/datasets")
# List datasets
async def get_datasets(
    search: Optional[str] = Query(default=None),
    active_only: Optional[bool] = Query(default=None),
    dataset_type_id: Optional[int] = Query(default=None),
    db: Database = Depends()):

    where_clauses = []
    values = []
    idx = 1

    if search:
        where_clauses.append(
            f"""(
                d.dataset_name ilike ${idx}
                or d.dataset_doi ilike ${idx}
                or dt.dataset_type_name ilike ${idx}
            )"""
        )
        values.append(f"%{search}%")
        idx += 1

    if active_only is True:
        where_clauses.append("d.active = true")

    if dataset_type_id is not None:
        where_clauses.append(f"d.dataset_type_id = ${idx}")
        values.append(dataset_type_id)
        idx += 1

    where_sql = f"where {' and '.join(where_clauses)}" if where_clauses else ""

    query = f"""\
        select
            d.dataset_id,
            d.dataset_type_id,
            dt.dataset_type_name,
            d.dataset_name,
            d.dataset_doi,
            d.active,
            d.who_created,
            d.when_created,
            d.who_updated,
            d.when_updated
        from
            dataset d
            join dataset_type dt using (dataset_type_id)
        {where_sql}
        order by d.dataset_id
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

    if payload.dataset_type_id <= 0 or not payload.dataset_name.strip() or not payload.dataset_doi.strip():
        api_error(
            "VALIDATION_ERROR",
            "Required dataset fields must be non-empty",
            {
                "required": [
                    "dataset_type_id",
                    "dataset_name",
                    "dataset_doi",
                ]
            },
            422,
        )

    query = """\
        with inserted as (
            insert into dataset (
                dataset_type_id,
                dataset_name,
                dataset_doi,
                active,
                when_created,
                when_updated,
                who_created,
                who_updated
            )
            values ($1, $2, $3, $4, now(), now(), $5, $5)
            returning
                dataset_id,
                dataset_type_id,
                dataset_name,
                dataset_doi,
                active,
                who_created,
                when_created,
                who_updated,
                when_updated
        )
        select
            i.dataset_id,
            i.dataset_type_id,
            dt.dataset_type_name,
            i.dataset_name,
            i.dataset_doi,
            i.active,
            i.who_created,
            i.when_created,
            i.who_updated,
            i.when_updated
        from inserted i
        join dataset_type dt using (dataset_type_id)
        """

    values = [
        payload.dataset_type_id,
        payload.dataset_name,
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
async def get_dataset(dataset_id: int, db: Database = Depends()):
    query = """\
        select
            d.dataset_id,
            d.dataset_type_id,
            dt.dataset_type_name,
            d.dataset_name,
            d.dataset_doi,
            d.active,
            d.who_created,
            d.when_created,
            d.who_updated,
            d.when_updated
        from
            dataset d
            join dataset_type dt using (dataset_type_id)
        where
            d.dataset_id = $1
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

    updates = []
    values = []
    idx = 1

    def add_text_field(column_name: str, value: Optional[str]):
        nonlocal idx
        if value is None:
            return

        if not value.strip():
            api_error("VALIDATION_ERROR", f"{column_name} must be non-empty", {"field": column_name}, 422)

        updates.append(f"{column_name} = ${idx}")
        values.append(value)
        idx += 1

    if payload.dataset_type_id is not None:
        updates.append(f"dataset_type_id = ${idx}")
        values.append(payload.dataset_type_id)
        idx += 1

    add_text_field("dataset_name", payload.dataset_name)
    add_text_field("dataset_doi", payload.dataset_doi)

    if payload.active is not None:
        updates.append(f"active = ${idx}")
        values.append(payload.active)
        idx += 1

    if not updates:
        api_error("VALIDATION_ERROR", "No dataset fields were provided", {}, 422)

    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${idx}")
    values.append(current_user.username)
    idx += 1

    dataset_id_placeholder = idx

    query = f"""\
        with updated as (
            update dataset
            set {', '.join(updates)}
            where dataset_id = ${dataset_id_placeholder}
            returning
                dataset_id,
                dataset_type_id,
                dataset_name,
                dataset_doi,
                active,
                who_created,
                when_created,
                who_updated,
                when_updated
        )
        select
            u.dataset_id,
            u.dataset_type_id,
            dt.dataset_type_name,
            u.dataset_name,
            u.dataset_doi,
            u.active,
            u.who_created,
            u.when_created,
            u.who_updated,
            u.when_updated
        from updated u
        join dataset_type dt using (dataset_type_id)
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
async def get_recordsets_for_dataset(
    dataset_id: int,
    active_only: Optional[bool] = Query(default=None),
    db: Database = Depends()):

    query = """\
        select
            rs.recordset_id,
            rs.recordset_doi,
            rs.recordset_type_id,
            rt.recordset_type_name,
            rs.recordset_name,
            rsl.license_id,
            rsl.license_name,
            rsl.license_label,
            rsl.license_url,
            rsl.is_public_access,
            rs.active
        from
            dataset
            join recordset rs using (dataset_id)
            join recordset_type rt using (recordset_type_id)
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
async def get_releases_for_dataset(
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
            join dataset_release dr using (dataset_id)
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

# -----------------------------------------DATASET RELEASES------------------------------------------------

@router.get("/datasets/releases/{release_id}")
# Get dataset release detail
async def get_dataset_release(release_id: int, db: Database = Depends()):
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
async def update_dataset_release(
    release_id: int,
    payload: DatasetReleaseUpdate,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    updates = []
    values = []
    idx = 1

    if payload.dataset_id is not None:
        updates.append(f"dataset_id = ${idx}")
        values.append(payload.dataset_id)
        idx += 1

    if payload.release_number is not None:
        updates.append(f"release_number = ${idx}")
        values.append(payload.release_number)
        idx += 1

    if payload.release_date is not None:
        updates.append(f"release_date = ${idx}")
        values.append(payload.release_date)
        idx += 1

    if payload.release_notes is not None:
        updates.append(f"release_notes = ${idx}")
        values.append(payload.release_notes)
        idx += 1

    if not updates:
        api_error("VALIDATION_ERROR", "No dataset release fields were provided", {}, 422)

    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${idx}")
    values.append(current_user.username)
    idx += 1

    release_id_placeholder = idx

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
async def get_recordsets_for_dataset_release(release_id: int, db: Database = Depends()):
    query = """\
        select
			rr.recordset_id,
            rr.recordset_release_id,
            rs.recordset_name,
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


@router.post("/datasets/releases/{release_id}/recordsets/add")
# Add recordset releases to a dataset release
async def add_recordset_release_to_dataset_release(
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


@router.post("/datasets/releases/{release_id}/recordsets/remove")
# Remove recordset releases from a dataset release
async def remove_recordset_release_from_dataset_release(
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
async def get_transfers_for_dataset_release(release_id: int, db: Database = Depends()):
    query = """\
        select
            drt.dataset_release_transfer_id,
            drt.destination_id,
            td.destination_name,
            td.destination_abbr,
            drt.transfer_name,
            drt.transfer_mode_id,
            tm.transfer_mode_name,
            drt.transfer_status,
            drt.transfer_notes
        from dataset_release_transfer drt
        join transfer_destination td using (destination_id)
        join transfer_mode tm using (transfer_mode_id)
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
async def create_transfer_for_dataset_release(release_id: int,payload: DatasetReleaseTransferInsert,  db: Database = Depends()):
    if payload.destination_id <= 0 or payload.transfer_mode_id <= 0 or not payload.transfer_name.strip():
        api_error(
            "VALIDATION_ERROR",
            "Required transfer fields must be non-empty",
            {"required": ["destination_id", "transfer_name", "transfer_mode_id"]},
            422,
        )

    query = """\
        with inserted as (
            insert into dataset_release_transfer
            (
                dataset_release_id,
                destination_id,
                transfer_name,
                transfer_mode_id,
                transfer_status,
                transfer_notes
            )
            values ($1, $2, $3, $4, $5, $6)
            returning
                dataset_release_transfer_id,
                destination_id,
                transfer_name,
                transfer_mode_id,
                transfer_status,
                transfer_notes
        )
        select
            i.dataset_release_transfer_id,
            i.destination_id,
            td.destination_name,
            td.destination_abbr,
            i.transfer_name,
            i.transfer_mode_id,
            tm.transfer_mode_name,
            i.transfer_status,
            i.transfer_notes
        from inserted i
        join transfer_destination td using (destination_id)
        join transfer_mode tm using (transfer_mode_id)
        """

    values = [
        release_id,
        payload.destination_id,
        payload.transfer_name,
        payload.transfer_mode_id,
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
                r.recordset_name ilike ${idx}
                or r.recordset_doi ilike ${idx}
                or rt.recordset_type_name ilike ${idx}
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
            d.dataset_name,
            d.dataset_type_id,
            dt.dataset_type_name,
            r.license_id,
            rsl.license_name,
            rsl.license_label,
            rsl.license_url,
            rsl.is_public_access,
            r.recordset_type_id,
            rt.recordset_type_name,
            r.recordset_name,
            r.active,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated
        from
            recordset r
            join recordset_type rt using (recordset_type_id)
            join recordset_license rsl using (license_id)
            join dataset d using (dataset_id)
            join dataset_type dt using (dataset_type_id)
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
    db: Database = Depends()):

    if (
        not payload.recordset_doi.strip()
        or not payload.recordset_name.strip()
        or payload.recordset_type_id <= 0
        or payload.dataset_id <= 0
        or payload.license_id <= 0
    ):
        api_error(
            "VALIDATION_ERROR",
            "Required recordset fields must be non-empty",
            {
                "required": [
                    "recordset_doi",
                    "recordset_type_id",
                    "recordset_name",
                    "dataset_id",
                    "license_id",
                ]
            },
            422,
        )

    query = """\
        insert into recordset (
            recordset_doi,
            dataset_id,
            license_id,
            recordset_type_id,
            recordset_name,
            active,
            when_created,
            when_updated,
            who_created,
            who_updated
        )
        values ($1, $2, $3, $4, $5, $6, now(), now(), $7, $7)
        returning
            recordset_id,
            recordset_doi,
            dataset_id,
            license_id,
            recordset_type_id,
            recordset_name,
            active,
            when_created,
            when_updated
        """

    values = [
        payload.recordset_doi,
        payload.dataset_id,
        payload.license_id,
        payload.recordset_type_id,
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
async def get_recordset(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_id,
            r.recordset_doi,
            r.dataset_id,
            d.dataset_name,
            d.dataset_type_id,
            dt.dataset_type_name,
            r.recordset_type_id,
            rt.recordset_type_name,
            r.recordset_name,
            r.active,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated,
            rl.license_id,
            rl.license_name,
            rl.license_label,
            rl.license_url,
            rl.is_public_access
        from
            recordset r
            join recordset_type rt using (recordset_type_id)
            join recordset_license rl using (license_id)
            join dataset d using (dataset_id)
            join dataset_type dt using (dataset_type_id)
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


@router.put("/recordsets/{recordset_id}")
# Update recordset
async def update_recordset(
    recordset_id: int,
    payload: RecordsetUpdate,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    updates = []
    values = []
    idx = 1

    def add_text_field(column_name: str, value: Optional[str]):
        nonlocal idx
        if value is None:
            return

        if not value.strip():
            api_error("VALIDATION_ERROR", f"{column_name} must be non-empty", {"field": column_name}, 422)

        updates.append(f"{column_name} = ${idx}")
        values.append(value)
        idx += 1

    add_text_field("recordset_doi", payload.recordset_doi)
    add_text_field("recordset_name", payload.recordset_name)

    if payload.recordset_type_id is not None:
        updates.append(f"recordset_type_id = ${idx}")
        values.append(payload.recordset_type_id)
        idx += 1

    if payload.dataset_id is not None:
        updates.append(f"dataset_id = ${idx}")
        values.append(payload.dataset_id)
        idx += 1

    if payload.license_id is not None:
        updates.append(f"license_id = ${idx}")
        values.append(payload.license_id)
        idx += 1

    if payload.active is not None:
        updates.append(f"active = ${idx}")
        values.append(payload.active)
        idx += 1

    if not updates:
        api_error("VALIDATION_ERROR", "No recordset fields were provided", {}, 422)

    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${idx}")
    values.append(current_user.username)
    idx += 1

    recordset_id_placeholder = idx
    values.append(recordset_id)

    query = f"""\
        with updated as (
            update recordset
            set {', '.join(updates)}
            where recordset_id = ${recordset_id_placeholder}
            returning
                recordset_id,
                recordset_doi,
                dataset_id,
                license_id,
                recordset_type_id,
                recordset_name,
                active,
                when_created,
                who_created,
                when_updated,
                who_updated
        )
        select
            u.recordset_id,
            u.recordset_doi,
            u.dataset_id,
            d.dataset_name,
            d.dataset_type_id,
            dt.dataset_type_name,
            u.recordset_type_id,
            rt.recordset_type_name,
            u.recordset_name,
            u.active,
            u.when_created,
            u.who_created,
            u.when_updated,
            u.who_updated,
            rl.license_name,
            rl.license_id,
            rl.license_label,
            rl.license_url,
            rl.is_public_access
        from updated u
        join recordset_type rt using (recordset_type_id)
        join recordset_license rl using (license_id)
        join dataset d using (dataset_id)
        join dataset_type dt using (dataset_type_id)
        """

    try:
        record = await db.fetch(query, values)
    except Exception as e:
        db_error(
            e,
            operation="updating recordset",
            context={"recordset_id": recordset_id},
        )

    if not record:
        api_error("NOT_FOUND", "Recordset not found", {"recordset_id": recordset_id}, 404)

    return item_response(record[0])


@router.get("/recordsets/{recordset_id}/drafts")
# List draft releases for a recordset
async def get_recordset_drafts(recordset_id: int, db: Database = Depends()):
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
            r.who_updated,
            count(rdf.file_id)::int as file_count
        from
            recordset_draft r
            left join recordset_draft_file rdf using (recordset_draft_id)
        where
            r.recordset_id = $1
        and
            r.draft_status <> 'deleted'
        group by
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
        order by
            r.recordset_draft_id;
        """
    try:
        records = await db.fetch(query, [recordset_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset drafts",
            context={"recordset_id": recordset_id},
        )

    return list_response(records)


@router.get("/recordsets/{recordset_id}/releases")
# List immutable releases for a recordset
async def get_recordset_releases(recordset_id: int, db: Database = Depends()):
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
            r.who_updated,
            count(rrf.file_id)::int as file_count
        from
            recordset_release r
            left join recordset_release_file rrf using (recordset_release_id)
        where
            r.recordset_id = $1
        group by
            r.recordset_release_id,
            r.recordset_id,
            r.release_number,
            r.release_date,
            r.release_notes,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated
        order by
            r.release_number;
        """
    try:
        records = await db.fetch(query, [recordset_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset releases",
            context={"recordset_id": recordset_id},
        )

    return list_response(records)


@router.get("/recordsets/{recordset_id}/destinations")
# List destinations for a recordset
async def get_recordset_destinations(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            rd.destination_id,
            td.destination_name,
            td.destination_abbr,
            rd.default_display,
            rd.transfer_mode_id,
            tm.transfer_mode_name
        from recordset_destination rd
            join transfer_destination td using (destination_id)
            join transfer_mode tm using (transfer_mode_id)
        where
            rd.recordset_id = $1;
        """
    try:
        records = await db.fetch(query, [recordset_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset destinations",
            context={"recordset_id": recordset_id},
        )
    return list_response(records)


# -----------------------------------------RECORDSET DESTINATIONS------------------------------------------------

@router.get("/recordsets/{recordset_id}/destinations/{destination_id}")
# Get a destination specific configuration for a recordset
async def get_recordset_destination(recordset_id: int, destination_id: int, db: Database = Depends()):
    query = """\
        select
            rd.destination_id,
            td.destination_name,
            td.destination_abbr,
            rd.default_display,
            rd.transfer_mode_id,
            tm.transfer_mode_name
        from recordset_destination rd
            join transfer_destination td using (destination_id)
            join transfer_mode tm using (transfer_mode_id)
        where
            rd.recordset_id = $1 and rd.destination_id = $2;
        """
    try:
        records = await db.fetch(query, [recordset_id, destination_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching a recordset destination",
            context={"recordset_id": recordset_id, "destination_id": destination_id},
        )
    return list_response(records)


@router.put("/recordsets/{recordset_id}/destinations/{destination_id}")
# Create or update a destination configuration for a recordset
async def update_recordset_destination(
    recordset_id: int,
    destination_id: int,
    payload: DestinationUpdate,
    db: Database = Depends()
):
    updates = []
    update_values = []
    idx = 3

    if payload.default_display is not None:
        updates.append(f"default_display = ${idx}")
        update_values.append(payload.default_display)
        idx += 1

    if payload.default_transfer_mode_id is not None:
        updates.append(f"transfer_mode_id = ${idx}")
        update_values.append(payload.default_transfer_mode_id)
        idx += 1

    if not updates:
        api_error("VALIDATION_ERROR", "No destination fields were provided", {}, 422)

    exists_query = """\
        select 1
        from recordset_destination
        where recordset_id = $1 and destination_id = $2
        limit 1
    """

    clear_default_query = """\
        update recordset_destination
        set default_display = false
        where recordset_id = $1
          and destination_id <> $2
          and default_display = true
    """

    insert_query = """\
        insert into recordset_destination (
            recordset_id,
            destination_id,
            default_display,
            transfer_mode_id
        )
        values ($1, $2, $3, $4)
        returning *
    """

    record = []

    try:
        async with db.transaction() as conn:
            existing = await conn.fetch(exists_query, recordset_id, destination_id)

            if existing:
                if payload.default_display is True:
                    await conn.execute(clear_default_query, recordset_id, destination_id)

                update_query = f"""\
                    update recordset_destination
                    set {', '.join(updates)}
                    where recordset_id = $1 and destination_id = $2
                    returning *
                """

                record = await conn.fetch(
                    update_query,
                    recordset_id,
                    destination_id,
                    *update_values,
                )
            else:
                if payload.default_display is None or payload.default_transfer_mode_id is None:
                    api_error(
                        "VALIDATION_ERROR",
                        "default_display and default_transfer_mode_id are required for insert",
                        {
                            "required": ["default_display", "default_transfer_mode_id"],
                            "recordset_id": recordset_id,
                            "destination_id": destination_id,
                        },
                        422,
                    )

                if payload.default_display is True:
                    await conn.execute(clear_default_query, recordset_id, destination_id)

                record = await conn.fetch(
                    insert_query,
                    recordset_id,
                    destination_id,
                    payload.default_display,
                    payload.default_transfer_mode_id,
                )
    except Exception as e:
        db_error(
            e,
            operation="upserting recordset destination",
            context={"recordset_id": recordset_id, "destination_id": destination_id},
        )

    if not record:
        api_error(
            "INTERNAL_ERROR",
            "Upsert failed",
            {"recordset_id": recordset_id, "destination_id": destination_id},
            500,
        )

    return item_response(record[0])

# -----------------------------------------RECORDSET DRAFTS-----------------------------------------------

@router.post("/recordsets/{recordset_id}/drafts")
# Create draft release
async def create_recordset_draft(
    recordset_id: int,
    payload: RecordsetDraftInsert,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    if not payload.draft_name.strip():
        api_error(
            "VALIDATION_ERROR",
            "Required recordset draft fields must be non-empty",
            {"required": ["draft_name"]},
            422,
        )

    query = """\
        insert into recordset_draft (
            recordset_id,
            cloned_from_release_id,
            draft_name,
            draft_notes,
            draft_status,
            when_created,
            when_updated,
            who_created,
            who_updated
        )
        values ($1, $2, $3, $4, $5, now(), now(), $6, $6)
        returning *;
    """

    validate_release_query = """\
        select 1
        from recordset_release
        where recordset_release_id = $1
        limit 1;
    """

    clone_files_query = """\
        insert into recordset_draft_file (recordset_draft_id, file_id)
        select $1, rrf.file_id
        from recordset_release_file rrf
        where rrf.recordset_release_id = $2
        on conflict do nothing;
    """

    values = [
        recordset_id,
        payload.cloned_from_release_id,
        payload.draft_name,
        payload.draft_notes,
        payload.draft_status,
        current_user.username,
    ]

    try:
        async with db.transaction() as conn:
            if payload.cloned_from_release_id is not None:
                release_record = await conn.fetch(
                    validate_release_query,
                    payload.cloned_from_release_id,
                )

                if not release_record:
                    api_error(
                        "VALIDATION_ERROR",
                        "Invalid cloned_from_release_id",
                        {
                            "cloned_from_release_id": payload.cloned_from_release_id,
                        },
                        422,
                    )

            record = await conn.fetch(query, *values)

            if payload.cloned_from_release_id is not None:
                await conn.execute(
                    clone_files_query,
                    record[0]["recordset_draft_id"],
                    payload.cloned_from_release_id,
                )
    except HTTPException:
        raise
    except Exception as e:
        db_error(
            e,
            operation="creating recordset draft",
            context={"recordset_id": recordset_id},
        )

    return item_response(record[0])


@router.get("/recordsets/drafts/{draft_id}")
# Get draft detail
async def get_recordset_draft(
    draft_id: int,
    db: Database = Depends()):

    query = """\
        select
            rd.recordset_draft_id,
            rd.recordset_id,
            rd.cloned_from_release_id,
            rd.draft_name,
            rd.draft_status,
            rd.draft_notes,
            rd.when_created,
            rd.who_created,
            rd.when_updated,
            rd.who_updated
        from
            recordset_draft rd
        where
            rd.recordset_draft_id = $1;
        """
    try:
        record = await db.fetch_one(query, [draft_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset draft",
            context={"draft_id": draft_id},
        )

    if not record:
        api_error("NOT_FOUND", "Recordset draft not found", {"draft_id": draft_id}, 404)

    return item_response(record)


@router.put("/recordsets/drafts/{draft_id}")
# Update draft metadata
async def update_recordset_draft(
    draft_id: int,
    payload: RecordsetDraftUpdate,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    updates = []
    values = []
    idx = 1

    if payload.recordset_id is not None:
        updates.append(f"recordset_id = ${idx}")
        values.append(payload.recordset_id)
        idx += 1

    if payload.draft_name is not None:
        updates.append(f"draft_name = ${idx}")
        values.append(payload.draft_name)
        idx += 1

    if payload.draft_notes is not None:
        updates.append(f"draft_notes = ${idx}")
        values.append(payload.draft_notes)
        idx += 1

    if payload.draft_status is not None:
        updates.append(f"draft_status = ${idx}")
        values.append(payload.draft_status)
        idx += 1

    if payload.cloned_from_release_id is not None:
        updates.append(f"cloned_from_release_id = ${idx}")
        values.append(payload.cloned_from_release_id)
        idx += 1

    if not updates:
        api_error("VALIDATION_ERROR", "No recordset draft fields were provided", {}, 422)

    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${idx}")
    values.append(current_user.username)
    idx += 1

    draft_id_placeholder = idx

    query = f"""\
        update
            recordset_draft
            set {', '.join(updates)}
            where recordset_draft_id = ${draft_id_placeholder}
        returning *;
    """
    values.append(draft_id)

    try:
        record = await db.fetch_one(query, values)
    except Exception as e:
        db_error(e, operation="updating recordset draft", context={"draft_id": draft_id})

    if not record:
        api_error("NOT_FOUND", "Draft recordset not found", {"draft_id": draft_id}, 404)

    return item_response(record)


@router.delete("/recordsets/drafts/{draft_id}")
# Delete draft
async def delete_recordset_draft(
    draft_id: int,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    delete_query = """\
        update recordset_draft
        set
            draft_status = 'deleted',
            when_updated = now(),
            who_updated = $2
        where recordset_draft_id = $1
        returning *;
    """

    try:
        record = await db.fetch_one(delete_query, [draft_id, current_user.username])
    except Exception as e:
        db_error(
            e,
            operation="deleting recordset draft",
            context={"draft_id": draft_id},
        )

    if not record:
        api_error("NOT_FOUND", "Draft not found", {"draft_id": draft_id}, 404)

    return item_response(record)


@router.get("/recordsets/drafts/{draft_id}/files")
# List files in a draft
async def get_recordset_draft_files(
    draft_id: int,
    db: Database = Depends()):

    query = """\
        select
            rf.file_id
        from
            recordset_draft_file rf
        where
            rf.recordset_draft_id = $1;
        """
    try:
        records = await db.fetch(query, [draft_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset draft files",
            context={"draft_id": draft_id},
        )

    return list_response(records)


@router.get("/recordsets/drafts/{draft_id}/summary")
async def get_recordset_draft_summary(
    draft_id: int,
    db: Database = Depends()):

    q_check = """
        select recordset_draft_id
        from recordset_draft
        where recordset_draft_id = $1
    """

    q_by_type = """
        select
            coalesce(f.file_type, 'unknown') as file_type,
            count(*)::int                     as file_count,
            coalesce(sum(f.size), 0)::bigint  as total_size_bytes
        from recordset_draft_file rdf
        join file f using (file_id)
        where rdf.recordset_draft_id = $1
        group by f.file_type
        order by file_count desc
    """

    q_dicom = """
        select
            count(distinct fp.patient_id)::int          as patient_count,
            count(distinct fs.study_instance_uid)::int  as study_count,
            count(distinct fse.series_instance_uid)::int as series_count
        from recordset_draft_file rdf
        join file f using (file_id)
        left join file_patient  fp  using (file_id)
        left join file_study    fs  using (file_id)
        left join file_series   fse using (file_id)
        where rdf.recordset_draft_id = $1
          and f.is_dicom_file = true
    """

    q_modality = """
        select
            coalesce(fse.modality, 'unknown')            as modality,
            count(distinct fse.series_instance_uid)::int as series_count,
            count(*)::int                                as file_count
        from recordset_draft_file rdf
        join file f using (file_id)
        join file_series fse using (file_id)
        where rdf.recordset_draft_id = $1
          and f.is_dicom_file = true
        group by fse.modality
        order by series_count desc
    """

    try:
        draft = await db.fetch_one(q_check, [draft_id])
        if not draft:
            api_error("NOT_FOUND", "Recordset draft not found", {"draft_id": draft_id}, 404)

        by_type   = await db.fetch(q_by_type,  [draft_id])
        dicom     = await db.fetch_one(q_dicom, [draft_id])
        modalities = await db.fetch(q_modality, [draft_id])
    except HTTPException:
        raise
    except Exception as e:
        db_error(e, operation="fetching draft summary", context={"draft_id": draft_id})

    return item_response({
        "draft_id":         draft_id,
        "total_files":      sum(r["file_count"] for r in by_type),
        "total_size_bytes": sum(r["total_size_bytes"] for r in by_type),
        "by_file_type":     [dict(r) for r in by_type],
        "dicom": {
            "patient_count":  dicom["patient_count"],
            "study_count":    dicom["study_count"],
            "series_count":   dicom["series_count"],
            "by_modality":    [dict(r) for r in modalities],
        },
    })



@router.post("/recordsets/drafts/{draft_id}/files/add")
# Add files to a draft
async def add_recordset_draft_files(
    draft_id: int,
    payload: RecordsetDraftFileAdd,
    db: Database = Depends()):

    add_query = """
            insert into recordset_draft_file (recordset_draft_id, file_id)
            values ($1, $2)
            on conflict do nothing
            returning file_id;
        """

    count_query = """
            select count(*) as current_count
            from recordset_draft_file
            where recordset_draft_id = $1
        """

    file_ids = payload.file_ids

    if not file_ids:
        api_error(
            "VALIDATION_ERROR",
            "No files to add",
            {"file_ids": []},
            422,
        )

    added_file_ids = []
    exists_file_ids = []

    try:
        async with db.transaction() as conn:
            for file_id in file_ids:
                record = await conn.fetch(add_query, draft_id, file_id)
                if record:
                    added_file_ids.append(record[0]["file_id"])
                elif file_id not in exists_file_ids:
                    exists_file_ids.append(file_id)

            count_record = await conn.fetch(count_query, draft_id)
    except Exception as e:
        db_error(
            e,
            operation="adding files to recordset draft",
            context={"draft_id": draft_id},
        )

    return item_response(
        {
            "draft_id": draft_id,
            "added_file_ids": added_file_ids,
            "exists_file_ids": exists_file_ids,
            "current_count": count_record[0]["current_count"] if count_record else 0,
        }
    )


@router.post("/recordsets/drafts/{draft_id}/files/remove")
# Remove files from a draft
async def remove_recordset_draft_files(
    draft_id: int,
    payload: RecordsetDraftFileRemove,
    db: Database = Depends()):

    remove_query = """
            delete from recordset_draft_file
            where recordset_draft_id = $1 and file_id = $2
            returning file_id;
        """
    count_query = """
            select count(*) as current_count
            from recordset_draft_file
            where recordset_draft_id = $1
        """

    file_ids = payload.file_ids

    if not file_ids:
        api_error(
            "VALIDATION_ERROR",
            "No files to remove",
            {"file_ids": []},
            422,
        )

    removed_file_ids = []
    not_exists_file_ids = []

    try:
        async with db.transaction() as conn:
            for file_id in file_ids:
                record = await conn.fetch(remove_query, draft_id, file_id)
                if record:
                    removed_file_ids.append(record[0]["file_id"])
                elif file_id not in not_exists_file_ids:
                    not_exists_file_ids.append(file_id)

            count_record = await conn.fetch(count_query, draft_id)
    except Exception as e:
        db_error(
            e,
            operation="removing files from recordset draft",
            context={"draft_id": draft_id},
        )

    return item_response(
        {
            "draft_id": draft_id,
            "removed_file_ids": removed_file_ids,
            "not_exists_file_ids": not_exists_file_ids,
            "current_count": count_record[0]["current_count"] if count_record else 0,
        }
    )



class DraftDiffResponse(BaseModel):
    draft_id: int
    compare_type: str  # "release" | "draft" | "activity"
    compare_id: int
    compare_timepoint_id: Optional[int] = None
    added_file_ids: list[int]
    removed_file_ids: list[int]
    added_count: int
    removed_count: int
    unchanged_count: int


@router.get("/recordsets/drafts/{draft_id}/diff")
async def get_recordset_draft_diff(
    draft_id: int,
    compare_release_id: Optional[int] = None,
    compare_draft_id: Optional[int] = None,
    compare_activity_id: Optional[int] = None,
    compare_timepoint_id: Optional[int] = None,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> DraftDiffResponse:
    """
    Compare a draft against a release, another draft, or an activity timepoint.
    Exactly one of compare_release_id, compare_draft_id, or compare_activity_id
    must be provided. If none are provided, defaults to the latest release for
    the same recordset. compare_timepoint_id is only valid with compare_activity_id
    and defaults to the latest timepoint for that activity.
    """
    draft = await db.fetch_one(
        """
        select recordset_draft_id, recordset_id
        from recordset_draft
        where recordset_draft_id = $1
        """,
        [draft_id],
    )
    if draft is None:
        raise HTTPException(status_code=404, detail=f"Draft {draft_id} not found")

    provided = sum([
        compare_release_id is not None,
        compare_draft_id is not None,
        compare_activity_id is not None,
    ])
    if provided > 1:
        raise HTTPException(
            status_code=422,
            detail="Only one of compare_release_id, compare_draft_id, or compare_activity_id may be provided",
        )
    if compare_timepoint_id is not None and compare_activity_id is None:
        raise HTTPException(
            status_code=422,
            detail="compare_timepoint_id requires compare_activity_id",
        )

    added_file_ids: list[int] = []
    removed_file_ids: list[int] = []
    compare_type: str
    compare_id: int
    resolved_timepoint_id: Optional[int] = None

    if compare_activity_id is not None:
        compare_type = "activity"
        compare_id = compare_activity_id

        if compare_timepoint_id is not None:
            tp = await db.fetch_one(
                """
                select activity_timepoint_id
                from activity_timepoint
                where activity_timepoint_id = $1 and activity_id = $2
                """,
                [compare_timepoint_id, compare_activity_id],
            )
            if tp is None:
                raise HTTPException(
                    status_code=404,
                    detail=f"Timepoint {compare_timepoint_id} not found for activity {compare_activity_id}",
                )
            resolved_timepoint_id = compare_timepoint_id
        else:
            latest_tp = await db.fetch_one(
                """
                select activity_timepoint_id
                from activity_timepoint
                where activity_id = $1
                order by when_created desc
                limit 1
                """,
                [compare_activity_id],
            )
            if latest_tp is None:
                raise HTTPException(
                    status_code=404,
                    detail=f"No timepoints found for activity {compare_activity_id}",
                )
            resolved_timepoint_id = latest_tp["activity_timepoint_id"]

        added = await db.fetch(
            """
            select file_id from recordset_draft_file where recordset_draft_id = $1
            except
            select file_id from activity_timepoint_file where activity_timepoint_id = $2
            """,
            [draft_id, resolved_timepoint_id],
        )
        removed = await db.fetch(
            """
            select file_id from activity_timepoint_file where activity_timepoint_id = $1
            except
            select file_id from recordset_draft_file where recordset_draft_id = $2
            """,
            [resolved_timepoint_id, draft_id],
        )

    elif compare_draft_id is not None:
        compare_type = "draft"
        compare_id = compare_draft_id

        other = await db.fetch_one(
            "select recordset_draft_id from recordset_draft where recordset_draft_id = $1",
            [compare_draft_id],
        )
        if other is None:
            raise HTTPException(status_code=404, detail=f"Draft {compare_draft_id} not found")

        added = await db.fetch(
            """
            select file_id from recordset_draft_file where recordset_draft_id = $1
            except
            select file_id from recordset_draft_file where recordset_draft_id = $2
            """,
            [draft_id, compare_draft_id],
        )
        removed = await db.fetch(
            """
            select file_id from recordset_draft_file where recordset_draft_id = $1
            except
            select file_id from recordset_draft_file where recordset_draft_id = $2
            """,
            [compare_draft_id, draft_id],
        )

    else:
        compare_type = "release"

        if compare_release_id is None:
            latest_release = await db.fetch_one(
                """
                select recordset_release_id
                from recordset_release
                where recordset_id = $1
                order by release_number desc
                limit 1
                """,
                [draft["recordset_id"]],
            )
            if latest_release is None:
                # No prior release — everything in the draft is new
                all_files = await db.fetch(
                    "select file_id from recordset_draft_file where recordset_draft_id = $1",
                    [draft_id],
                )
                added_file_ids = [r["file_id"] for r in all_files]
                return DraftDiffResponse(
                    draft_id=draft_id,
                    compare_type="release",
                    compare_id=0,
                    added_file_ids=added_file_ids,
                    removed_file_ids=[],
                    added_count=len(added_file_ids),
                    removed_count=0,
                    unchanged_count=0,
                )
            compare_release_id = latest_release["recordset_release_id"]

        release = await db.fetch_one(
            "select recordset_release_id from recordset_release where recordset_release_id = $1",
            [compare_release_id],
        )
        if release is None:
            raise HTTPException(status_code=404, detail=f"Release {compare_release_id} not found")

        compare_id = compare_release_id

        added = await db.fetch(
            """
            select file_id from recordset_draft_file where recordset_draft_id = $1
            except
            select file_id from recordset_release_file where recordset_release_id = $2
            """,
            [draft_id, compare_release_id],
        )
        removed = await db.fetch(
            """
            select file_id from recordset_release_file where recordset_release_id = $1
            except
            select file_id from recordset_draft_file where recordset_draft_id = $2
            """,
            [compare_release_id, draft_id],
        )

    added_file_ids = [r["file_id"] for r in added]
    removed_file_ids = [r["file_id"] for r in removed]

    # unchanged_count_row = await db.fetch_one(
    #     """
    #     select count(*)::int as unchanged_count
    #     from recordset_draft_file
    #     where recordset_draft_id = $1
    #       and file_id = any($2::int[])
    #     """,
    #     [draft_id, [r["file_id"] for r in (await db.fetch(
    #         "select file_id from recordset_draft_file where recordset_draft_id = $1",
    #         [draft_id],
    #     ))]],
    # )

    total_draft = await db.fetch_one(
        "select count(*)::int as n from recordset_draft_file where recordset_draft_id = $1",
        [draft_id],
    )
    unchanged_count = (total_draft["n"] if total_draft else 0) - len(added_file_ids)

    return DraftDiffResponse(
        draft_id=draft_id,
        compare_type=compare_type,
        compare_id=compare_id,
        compare_timepoint_id=resolved_timepoint_id,
        added_file_ids=added_file_ids,
        removed_file_ids=removed_file_ids,
        added_count=len(added_file_ids),
        removed_count=len(removed_file_ids),
        unchanged_count=max(unchanged_count, 0),
    )


# TODO: This needs more thought.
# What validations do we want to perform before allowing a draft to be published?
# Do we want to block publish if there are warnings (e.g. files that are in the draft but not in the base release)?
# Do we want to allow users to override warnings and publish anyway?

# @router.post("/recordsets/drafts/{draft_id}/validate")
# # Validate draft before publish
# #   1.  Files exist in this draft
# async def validate_draft(draft_id: int, db: Database = Depends()):
#     query = """
#         select 1
#         from recordset_draft_file
#         where recordset_draft_id = $1
#         limit 1;
#     """

#     try:
#         row = await db.fetchrow(query, [draft_id])
#     except Exception as e:
#         db_error(
#             e,
#             operation="validating draft",
#             context={"draft_id": draft_id},
#         )
#         raise

#     if not row:
#         return {
#             "data": {
#                 "recordset_draft_id": draft_id,
#                 "valid": False,
#                 "errors": ["Draft has no files"],
#             }
#         }

#     return {
#         "data": {
#             "recordset_draft_id": draft_id,
#             "valid": True,
#             "errors": [],
#         }
#     }


@router.post("/recordsets/drafts/{draft_id}/publish")
# Publish a draft to an immutable recordset release
async def create_recordset_release(
    draft_id: int,
    payload: RecordsetReleaseInsert,
    current_user: User = logged_in_user,
    db: Database = Depends()):

    q_get_recordset = """
        select recordset_id
        from recordset_draft
        where recordset_draft_id = $1;
    """

    q_insert_release = """
        insert into recordset_release (
            recordset_id,
            release_number,
            release_date,
            release_notes,
            when_created,
            who_created,
            when_updated,
            who_updated
        )
        values ($1, $2, $3, $4, now(), $5, now(), $5)
        returning recordset_release_id;
    """

    q_copy_files = """
        insert into recordset_release_file (recordset_release_id, file_id)
        select $1, file_id
        from recordset_draft_file
        where recordset_draft_id = $2;
    """

    q_mark_draft_published = """
        update recordset_draft
        set
            draft_status = 'published',
            when_updated = now(),
            who_updated = $2
        where recordset_draft_id = $1;
    """

    try:
        async with db.transaction() as conn:
            # 1. Get recordset_id from draft
            draft_rows = await conn.fetch(q_get_recordset, draft_id)
            if not draft_rows:
                raise HTTPException(status_code=404, detail="Draft not found")
            draft_row = draft_rows[0]

            recordset_id = draft_row["recordset_id"]

            # 2. Create release
            release_rows = await conn.fetch(
                q_insert_release,
                recordset_id,
                payload.release_number,
                payload.release_date,
                payload.release_notes,
                current_user.username,
            )

            if not release_rows:
                raise HTTPException(status_code=500, detail="Failed to create release")
            release_row = release_rows[0]

            release_id = release_row["recordset_release_id"]

            # 3. Copy files from draft → release
            await conn.execute(q_copy_files, release_id, draft_id)

            # 4. Mark draft as published
            await conn.execute(q_mark_draft_published, draft_id, current_user.username)

    except Exception as e:
        db_error(
            e,
            operation="publishing recordset draft",
            context={"draft_id": draft_id},
        )
        raise

    return item_response(
        {
            "recordset_release_id": release_id,
            "recordset_id": recordset_id,
        }
    )


# -----------------------------------------RECORDSET RELEASES-----------------------------------------------

@router.get("/recordsets/releases/{release_id}")
#Get release details
async def get_recordset_release(release_id: int, db: Database = Depends()):
    query = """
        select
            r.recordset_release_id,
            r.recordset_id,
            r.release_number,
            r.release_date,
            r.release_notes,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated,
            count(rrf.file_id)::int as file_count
        from recordset_release r
        left join recordset_release_file rrf using (recordset_release_id)
        where r.recordset_release_id = $1
        group by
            r.recordset_release_id,
            r.recordset_id,
            r.release_number,
            r.release_date,
            r.release_notes,
            r.when_created,
            r.who_created,
            r.when_updated,
            r.who_updated;
    """

    try:
        record = await db.fetch(query, [release_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset release",
            context={"release_id": release_id},
        )

    if not record:
        api_error("NOT_FOUND", "Recordset release not found", {"release_id": release_id}, 404)

    return item_response(record[0])


@router.get("/recordsets/releases/{release_id}/files")
# List files in a release
async def get_recordset_release_files(release_id: int, db: Database = Depends()):
    query = """\
        select
            rf.file_id
        from
            recordset_release_file rf
        where
            rf.recordset_release_id = $1;
        """
    try:
        records = await db.fetch(query, [release_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset release files",
            context={"release_id": release_id},
        )
    return list_response(records)


#/papi/v1/distribution/recordsets/releases/{release_id}/diff/{other_release_id}
@router.get("/recordsets/releases/{release_id}/diff/{other_release_id}")
# Compare two immutable releases
async def get_release_diff(release_id: int, other_release_id: int, db: Database = Depends()):
    q_rel1_files = """
        select rf.file_id
        from recordset_release_file rf
        where rf.recordset_release_id = $1;
    """

    q_rel2_files = """
        select rf.file_id
        from recordset_release_file rf
        where rf.recordset_release_id = $1;
    """

    rel1_rows = await db.fetch(q_rel1_files, [release_id])
    rel2_rows = await db.fetch(q_rel2_files, [other_release_id])

    if not rel1_rows or not rel2_rows:
        raise HTTPException(status_code=404, detail="Base release not found")

    # Convert to sets
    rel1_file_ids = {r["file_id"] for r in rel1_rows}
    rel2_file_ids = {r["file_id"] for r in rel2_rows}

    # Diff
    added_file_ids = list(rel1_file_ids - rel2_file_ids)
    removed_file_ids = list(rel2_file_ids - rel1_file_ids)
    unchanged_count = len(rel1_file_ids & rel2_file_ids)

    records = {
        "left_release_id": release_id,
        "right_release_id": other_release_id,
        "added_file_ids": added_file_ids,
        "removed_file_ids": removed_file_ids,
        "summary": {
            "added_count": len(added_file_ids),
            "removed_count": len(removed_file_ids),
            "unchanged_count": unchanged_count,
        },
    }

    return {"data": records}


# ----------------------------------------Dataset release transfers-----------------------------------------------

@router.get("/transfers/{transfer_id}")
# Get details for a dataset release transfer
async def get_dataset_release_transfer_by_id(transfer_id: int,  db: Database = Depends()):
    query = """\
        select
            dataset_release_transfer_id,
            dataset_release_id,
            destination_id,
            transfer_name,
            transfer_mode_id,
            tm.transfer_mode_name,
            transfer_status,
            transfer_notes,
            when_created,
            when_updated
            from
                dataset_release_transfer drt
                join transfer_mode tm using (transfer_mode_id)
            where
                drt.dataset_release_transfer_id = $1;
        """
    try:
        record = await db.fetchrow(query, [transfer_id])
    except Exception as e:
        db_error(
            e,
            operation="fetching dataset release transfer",
            context={"transfer_id": transfer_id},
        )
        api_error("DB_ERROR", "Failed to fetch transfer", {}, 500)

    if not record:
        api_error("NOT_FOUND", "Dataset release transfer not found", {"transfer_id": transfer_id}, 404)

    return item_response(record)

@router.put("/transfers/{transfer_id}")
# Update details for a dataset release transfer
async def update_dataset_release_transfer(
    transfer_id: int, payload: DatasetReleaseTransferUpdate, current_user: User = logged_in_user, db: Database = Depends()):

    updates = []
    values = []
    idx = 1

    if payload.transfer_name is not None:
        updates.append(f"transfer_name = ${idx}")
        values.append(payload.transfer_name)
        idx += 1

    if payload.transfer_mode_id is not None:
        updates.append(f"transfer_mode_id = ${idx}")
        values.append(payload.transfer_mode_id)
        idx += 1

    if payload.transfer_status is not None:
        updates.append(f"transfer_status = ${idx}")
        values.append(payload.transfer_status)
        idx += 1

    if payload.transfer_notes is not None:
        updates.append(f"transfer_notes = ${idx}")
        values.append(payload.transfer_notes)
        idx += 1

    if not updates:
        api_error("VALIDATION_ERROR", "No dataset release transfer fields were provided", {}, 422)

    updates.append("when_updated = now()")
    updates.append(f"who_updated = ${idx}")
    values.append(current_user.username)
    idx += 1

    transfer_id_placeholder = idx
    values.append(transfer_id)

    query = f"""\
        update
            dataset_release_transfer
            set {', '.join(updates)}
            where dataset_release_transfer_id = ${transfer_id_placeholder}
        returning *;
    """

    try:
        record = await db.fetchrow(query, values)
    except Exception as e:
        db_error(e, operation="updating dataset release transfer", context={"transfer_id": transfer_id})
        api_error("DB_ERROR", "Failed to update transfer", {}, 500)

    if not record:
        api_error("NOT_FOUND", "Dataset release transfer not found", {"transfer_id": transfer_id}, 404)

    return item_response(record)

# ---------------------------------------- Transfer recordset membership-----------------------------------------------

@router.get("/transfers/{transfer_id}/recordsets")
# List recordset releases included in a transfer
async def get_recordset_releases_by_transfer(transfer_id: int, db: Database = Depends()):
    query = """\
        select
          rr.recordset_release_id,
          r.recordset_id,
          r.recordset_name,
          tr.retriever_manifest_file_id
        from
            transfer_recordset tr
            join recordset_release rr on tr.recordset_release_id = rr.recordset_release_id
            join recordset r on rr.recordset_id = r.recordset_id
        where
            tr.dataset_release_transfer_id = $1;
        """
    try:
        records = await db.fetch(query, [transfer_id])
        return list_response(records)
    except Exception as e:
        db_error(
            e,
            operation="fetching recordset releases",
            context={"transfer_id": transfer_id},
        )
        return list_response([])

# NOTE:
# AI tools suggest that this is not optimal
# it mentions something about using a batched option
# which would look something like "insert into ... select unnest($2::int[])"
# I have left this out for consistentcy and readability, our other endpoints aren't using it
# If we expect a very large number of adds and removes it may be worth considering such optimizations
@router.post("/transfers/{transfer_id}/recordsets/add")
# Add recordset releases to a transfer
async def add_recordset_release_to_transfer(
    transfer_id: int,
    payload: TransferReleaseRecordsetRequest,
    db: Database = Depends()):

    insert_query = """
            insert into transfer_recordset
            (dataset_release_transfer_id, recordset_release_id)
            values ($1, $2)
            returning recordset_release_id
        """
    count_query = """
            select count(*) as current_count
            from transfer_recordset
            where dataset_release_transfer_id = $1
        """

    recordset_release_ids = payload.recordset_release_ids

    if not recordset_release_ids:
        return api_error(
            "VALIDATION_ERROR",
            "No records to insert",
            {"recordset_release_ids": []},
            422,
        )

    added_recordset_release_ids = []
    count_record = []

    try:
        for recordset_release_id in recordset_release_ids:
            record = await db.fetchrow(insert_query, [transfer_id, recordset_release_id])
            if record:
                added_recordset_release_ids.append(record[0]["recordset_release_id"])

        count_record = await db.fetch(count_query, [transfer_id])
    except Exception as e:
        db_error(
            e,
            operation="adding recordset releases to transfer",
            context={"transfer_id": transfer_id},
        )

    return item_response(
        {
            "dataset_transfer_id": transfer_id,
            "added_recordset_release_ids": added_recordset_release_ids,
            "current_count": count_record[0]["current_count"] if count_record else 0,
        }
    )


@router.post("/transfers/{transfer_id}/recordsets/remove")
# Remove recordset releases from a transfer
async def remove_recordset_release_from_transfer(
    transfer_id: int,
    payload: TransferReleaseRecordsetRequest,
    db: Database = Depends()):

    delete_query = """
            delete from transfer_recordset
            where dataset_release_transfer_id = $1 and recordset_release_id = $2
            returning recordset_release_id
        """
    count_query = """
            select count(*) as current_count
            from transfer_recordset
            where dataset_release_transfer_id = $1
        """

    recordset_release_ids = payload.recordset_release_ids

    if not recordset_release_ids:
        return api_error(
            "VALIDATION_ERROR",
            "No records to remove",
            {"recordset_release_ids": []},
            422,
        )

    removed_recordset_release_ids = []
    count_record = []

    try:
        for recordset_release_id in recordset_release_ids:
            record = await db.fetchrow(delete_query, [transfer_id, recordset_release_id])
            if record:
                removed_recordset_release_ids.append(record[0]["recordset_release_id"])

        count_record = await db.fetch(count_query, [transfer_id])
    except Exception as e:
        db_error(
            e,
            operation="removing recordset releases from dataset release",
            context={"transfer_id": transfer_id},
        )

    return item_response(
        {
            "dataset_transfer_id": transfer_id,
            "removed_recordset_release_ids": removed_recordset_release_ids,
            "current_count": count_record[0]["current_count"] if count_record else 0,
        }
    )
