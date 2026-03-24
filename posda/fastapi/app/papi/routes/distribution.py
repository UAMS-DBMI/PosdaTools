from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from .auth import logged_in_user, User

from ..util import Database

router = APIRouter(
    tags=["distribution"],
    dependencies=[logged_in_user]
)

# datasets
@router.get("/datasets/{dataset_id}")
async def get_datasets_by_id(dataset_id: int, db: Database = Depends()):
    query = """\
        select
            c.dataset_id,
            c.dataset_doi,
            c.dataset_title,
            c.dataset_short_title,
            c.dataset_name,
            c.when_created,
            latest_release.latest_release_id,
            my_recordsets.recordset_count
        from
            dataset c
            natural join
                (select
                    dataset_id,
                    max(dataset_release_id) as latest_release_id
                    from
                        dataset_release
                    where
                        dataset_id = $1
                    group by
                        dataset_id
                ) latest_release
            natural join
                (select
                    count(recordset_id) as recordset_count
                 from
                    dataset natural join recordset
                 where
                    dataset_id = $1) as my_recordsets
        where
            c.dataset_id = $1
        """
    return await db.fetch(query, [dataset_id])

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
