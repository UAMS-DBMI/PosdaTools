from fastapi import Depends, APIRouter, HTTPException, Query
from typing import Optional
from pydantic import BaseModel
import asyncpg
from .auth import logged_in_user, User

from ..util import Database

router = APIRouter(
    tags=["distribution"],
    dependencies=[logged_in_user]
)

# --- Models ---
class RecordsetUpdate(BaseModel):
    recordset_title: Optional[str] = None
    recordset_name: Optional[str] = None
    recordset_type: Optional[str] = None

class DatasetReleaseUpdate(BaseModel):
    release_notes: Optional[str] = "New release"

class DatasetReleaseTransferInsert(BaseModel):
    destination_id: int
    transfer_name: str
    transfer_mode: str
    transfer_notes:  Optional[str] = None
    transfer_status: Optional[str] = "draft"

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


def item_response(data):
    return {"data": data}


def list_response(rows):
    return {"data": rows, "meta": {"count": len(rows)}}


def api_error(code: str, message: str, details: Optional[dict] = None, status_code: int = 400):
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

    rows = await db.fetch(query, values)

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
    except asyncpg.exceptions.UniqueViolationError as e:
        api_error(
            "CONFLICT",
            "Dataset DOI already exists",
            {"exception": type(e).__name__, "message": str(e)},
            409,
        )
    except Exception as e:
        api_error(
            "INTERNAL_ERROR",
            "Unexpected server failure",
            {"exception": type(e).__name__, "message": str(e)},
            500,
        )

    return item_response(record[0])


@router.get("/datasets/{dataset_id}")
# Get dataset detail
async def get_datasets_by_id(dataset_id: int, db: Database = Depends()):
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
        api_error(
            "INTERNAL_ERROR",
            "Error fetching dataset",
            {"exception": type(e).__name__, "message": str(e)},
            500,
        )

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
    except asyncpg.exceptions.UniqueViolationError as e:
        api_error(
            "CONFLICT",
            "Dataset DOI already exists",
            {"exception": type(e).__name__, "message": str(e)},
            409,
        )
    except Exception as e:
        api_error(
            "INTERNAL_ERROR",
            "Unexpected server failure",
            {"exception": type(e).__name__, "message": str(e)},
            500,
        )

    if not record:
        api_error("NOT_FOUND", "Dataset not found", {"dataset_id": dataset_id}, 404)

    return item_response(record[0])



@router.get("/datasets/{dataset_id}/recordsets")
async def get_recordsets_by_dataset(dataset_id: int, db: Database = Depends()):
    query = """\
        select
            ds.recordset_id,
            ds.recordset_doi,
            ds.recordset_title,
            ds.recordset_type,
            dsl.license_label,
            dsl.license_url,
            dsl.is_public_access
        from
            dataset natural join recordset ds
            natural join recordset_license dsl
        where
            dataset_id = $1
        """
    return await db.fetch(query, [dataset_id])


@router.get("/datasets/{dataset_id}/releases")
async def get_releases_by_dataset(dataset_id: int, db: Database = Depends()):
    query = """\
        select
            cr.dataset_release_id,
            cr.release_number,
            cr.release_date,
            crds.recordset_release_id
        from
            dataset c
            natural join dataset_release cr
            natural join dataset_release_recordset crds
        where
            c.dataset_id = $1;
        """
    return await db.fetch(query, [dataset_id])


#Note added recordset_release_id as input
#This structure implies the recordset_release record was inserted prior to this call
#It also assumes that the PK and release number are auto-incrementing
@router.post("/datasets/{dataset_id}/releases/{recordset_release_id}")
async def add_release_to_dataset(dataset_id: int, recordset_release_id: int, db: Database = Depends()):
    record = await db.fetch("""\
        with new_release as (
            insert into dataset_release (dataset_id, release_date)
            values ($1, now())
            returning dataset_release_id
        )
        insert into dataset_release_recordset (dataset_release_id, recordset_release_id)
        select dataset_release_id, $2 from new_release
    """, [dataset_id,recordset_release_id])
    print(record)
    if not record:
        raise HTTPException(detail="Error updating edit status", status_code=422)
    return {
        'status': 'success',
    }


@router.get("/dataset-releases/{dataset_release_id}")
async def get_dataset_release_details_by_id(dataset_release_id: int, db: Database = Depends()):
    query = """\
        select
            cr.dataset_release_id,
            cr.release_number,
            cr.release_date,
            crds.recordset_release_id
        from
            dataset_release cr
            natural join dataset_release_recordset crds
        where
            cr.dataset_release_id = $1;
        """
    return await db.fetch(query, [dataset_release_id])


# -----------------------------------------RECORDSETS------------------------------------------------

#Purpose: List recordsets
@router.get("/recordsets")
async def get_dataset_recordsets( db: Database = Depends()):
    query = """\
        select
            r.recordset_id,
            r.recordset_doi,
            r.dataset_id,
            r.recordset_type,
            r.recordset_title,
            r.recordset_name
        from
            recordset r;
        """
    return await db.fetch(query)


#Purpose: Get recordset detail
@router.get("/recordsets/{recordset_id}")
async def get_recordset_release_details_by_id(recordset_id: int, db: Database = Depends()):
    query = """\
        select
            r.recordset_id,
            r.recordset_doi,
            r.dataset_id,
            r.recordset_type,
            r.recordset_title,
            r.recordset_name,
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
            natural join recordset_license rl
        where
            r.recordset_id = $1;
        """
    return await db.fetch(query,[recordset_id])


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

# -----------------------------------------DATASET RELEASES------------------------------------------------

# Purpose: Get dataset release detail
@router.get("/datasets/releases/{release_id}")
async def get_dataset_release_by_id(release_id: int, db: Database = Depends()):
    query = """\
        select
            dr.dataset_release_id,
            dr.dataset_id,
            dr.release_number,
            dr.release_date,
            dr.release_notes,
            dr.when_created,
            dr.when_updated
        from dataset_release dr
        where dr.dataset_release_id = $1
        """
    return await db.fetch(query,[release_id])


# Purpose: Update dataset release metadata
@router.put("/datasets/releases/{release_id}")
async def update_dataset_release_by_id(release_id: int,  payload: DatasetReleaseUpdate, db: Database = Depends()):
    query = """
        update dataset_release
        set release_date = now(),
            release_notes = $2
        where dataset_release_id = $1
        returning *
    """
    values = [release_id, payload.release_notes or "New release"]
    record = await db.fetch(query, values)
    if not record:
        raise HTTPException(status_code=422, detail="Error updating release")
    return {"status": "success"}


# Purpose: List recordset releases included in a dataset release
@router.get("/datasets/releases/{release_id}/recordsets")
async def get_recordsets_for_dataset_release_by_id(release_id: int, db: Database = Depends()):
    query = """\
        select
            rr.recordset_id,
            rr.recordset_release_id,
            rs.recordset_title,
            rr.release_number
        from dataset_release dr
        natural join recordset_release rr
        natural join recordset rs
        where dr.dataset_release_id = $1
        and rs.active ;
        """
    return await db.fetch(query,[release_id])


# Purpose: Add recordset releases to a dataset release
@router.post("/datasets/releases/{release_id}/recordsets:add")
async def add_recordset_release_to_dataset_release_by_id(release_id: int, recordset_release_ids: list[str], db: Database = Depends()):
    query = """
            insert into dataset_release_recordset
            (dataset_release_id, recordset_release_id)
            values ($1, $2)
        """
    if recordset_release_ids is None:
        raise HTTPException(status_code=400, detail="No records to insert")

    for recordset_release_id in recordset_release_ids:
        record = await db.fetch(query, [release_id, recordset_release_id])

        if not record:
            raise HTTPException(
                status_code=422,
                detail=f"Failed to insert recordset_release {recordset_release_id}"
            )
    return {"status": "success"}


# Purpose: Remove recordset releases from a dataset release
@router.post("/datasets/releases/{release_id}/recordsets:remove")
async def remove_recordset_release_from_dataset_release_by_id(release_id: int, recordset_release_ids: list[int], db: Database = Depends()):
    query = """
            delete from dataset_release_recordset
            where dataset_release_id = $1 and recordset_release_id = $2
        """
    if recordset_release_ids is None:
        raise HTTPException(status_code=400, detail="No records to remove")

    for recordset_release_id in recordset_release_ids:
        record = await db.fetch(query, [release_id, recordset_release_id])

        if not record:
            raise HTTPException(
                status_code=422,
                detail=f"Failed to remove recordset_release {recordset_release_id}"
            )
    return {"status": "success"}


# Purpose: List transfers for a dataset release
@router.get("/datasets/releases/{release_id}/transfers")
async def get_transfers_for_dataset_release_by_id(release_id: int, db: Database = Depends()):
    query = """\
        select
            drt.dataset_release_transfer_id,
            drt.destination_id,
            td."name",
            drt.transfer_name,
            drt.transfer_mode,
            drt.transfer_status
        from dataset_release_transfer drt
        natural join transfer_destination td
        where drt.dataset_release_id = $1;
        """
    return await db.fetch(query,[release_id])


# Purpose: Create transfer for a dataset release
@router.post("/datasets/releases/{release_id}/transfers")
async def create_transfer_for__dataset_release_by_id(release_id: int,payload: DatasetReleaseTransferInsert,  db: Database = Depends()):
    if payload.transfer_notes is not None:
        query = """
            insert into dataset_release_transfer
            (dataset_release_id, destination_id, transfer_name, transfer_mode, transfer_status, transfer_notes)
            values ($1,$2,$3,$4,$5,$6)
        """
        values = [
            release_id,
            payload.destination_id,
            payload.transfer_name,
            payload.transfer_mode,
            payload.transfer_status,
            payload.transfer_notes
        ]
    else:
        query = """
            insert into dataset_release_transfer
            (dataset_release_id, destination_id, transfer_name, transfer_mode, transfer_status)
            values ($1,$2,$3,$4,$5)
        """
        values = [
            release_id,
            payload.destination_id,
            payload.transfer_name,
            payload.transfer_mode,
            payload.transfer_status
        ]

    return await db.fetch(query, values)
