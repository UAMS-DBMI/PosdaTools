from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from .auth import logged_in_user, User

from ..util import Database

router = APIRouter(
    tags=["distribution"],
    dependencies=[logged_in_user]
)

# Collections

#Note, the datastructure diagram did not include some suggested data
# such as description and creation date
@router.get("/collections/{collection_id}")
async def get_collections_by_id(collection_id: int, db: Database = Depends()):
    query = """\
        select
            c.collection_id,
            c.collection_code,
            c.collection_name,
            latest_release.latest_release_id,
            my_datasets.dataset_count
        from
            collection c
            natural join
                (select
                    collection_id,
                    max(collection_release_id) as latest_release_id
                    from
                        collection_release
                    where
                        collection_id = $1
                    group by
                        collection_id
                ) latest_release
            natural join
                (select
                    count(dataset_id) as dataset_count
                 from
                    collection natural join dataset
                 where
                    collection_id = $1) as my_datasets
        where
            c.collection_id = $1
        """
    return await db.fetch(query, [collection_id])

@router.get("/collections/{collection_id}/datasets")
async def get_datasets_by_collection(collection_id: int, db: Database = Depends()):
    query = """\
        select
            ds.dataset_id,
            ds.dataset_doi,
            ds.dataset_title,
            ds.dataset_type,
            dsl.dataset_license_label,
            dsl.dataset_license_url
        from
            collection natural join dataset ds
            natural join dataset_license dsl
        where
            collection_id = $1
        """
    return await db.fetch(query, [collection_id])

@router.get("/collections/{collection_id}/releases")
async def get_releases_by_collection(collection_id: int, db: Database = Depends()):
    query = """\
        select
            cr.collection_release_id,
            cr.collection_release_num,
            cr.collection_release_date,
            crds.dataset_release_id
        from
            collection c
            natural join collection_release cr
            natural join collection_release_dataset crds
        where
            c.collection_id = $1;
        """
    return await db.fetch(query, [collection_id])

#Note added dataset_release_id as input
#This structure implies the dataset_release record was inserted prior to this call
#It also assumes that the PK and release number are auto-incrementing
@router.post("/collections/{collection_id}/releases/{dataset_release_id}")
async def add_release_to_collection(collection_id: int, dataset_release_id: int, db: Database = Depends()):
    record = await db.fetch("""\
        with new_release as (
            insert into collection_release (collection_id, collection_release_date)
            values ($1, now())
            returning collection_release_id
        )
        insert into collection_release_dataset (collection_release_id, dataset_release_id)
        select collection_release_id, $2 from new_release
    """, [collection_id,dataset_release_id])
    print(record)
    if not record:
        raise HTTPException(detail="Error updating edit status", status_code=422)
    return {
        'status': 'success',
    }

@router.get("/collection-releases/{collection_release_id}")
async def get_collection_release_details_by_id(collection_release_id: int, db: Database = Depends()):
    query = """\
        select
            cr.collection_release_id,
            cr.collection_release_num,
            cr.collection_release_date,
            crds.dataset_release_id
        from
            collection_release cr
            natural join collection_release_dataset crds
        where
            cr.collection_release_id = $1;
        """
    return await db.fetch(query, [collection_release_id])
