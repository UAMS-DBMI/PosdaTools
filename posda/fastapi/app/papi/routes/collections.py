from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

from .auth import logged_in_user, User
from ..util import Database

router = APIRouter(
    tags=["Collections"],
    dependencies=[logged_in_user]
)

class CollectionInfo(BaseModel):
    collection: str
    site: str
    file_count: int

class CollectionSiteInfo(CollectionInfo):
    patient_count: int

@router.get("/", response_model=List[CollectionInfo])
async def get_all_collections(
    collection: str = None,
    site: str = None,
    db: Database = Depends()) -> List[CollectionInfo]:
    """
    Get a list of collections in this Posda instance.

    If collection is set, it will return only collections with that exact name.
    If site is set, it will return only collections with that exact site name.

    If both are set, site is ignored.
    """
    async def get_collections_by_collection(collection_name):
        query = """
            select
                project_name as collection,
                site_name as site,
                count(file_id) as file_count
            from ctp_file
            where project_name = $1
            group by project_name, site_name
        """

        return await db.fetch(query, [collection_name])

    async def get_collections_by_site(site_name):
        query = """
            select
                project_name as collection,
                site_name as site,
                count(file_id) as file_count
            from ctp_file
            where site_name = $1
            group by project_name, site_name
        """

        return await db.fetch(query, [site_name])

    query = """
        select
            project_name as collection,
            site_name as site,
            count(file_id) as file_count
        from ctp_file
        group by project_name, site_name
    """

    if collection is not None:
        return await get_collections_by_collection(collection)

    if site is not None:
        return await get_collections_by_site(site)

    return await db.fetch(query)


@router.get("/{collection_name}/{site_name}", response_model=CollectionSiteInfo)
async def get_collection_info(collection_name: str, site_name: str, db: Database = Depends()):
    query = """
        select 
            project_name as collection,
            site_name as site,
            count(file_id) as file_count,
            count(distinct patient_name) as patient_count
        from ctp_file
        natural join file_patient
        where project_name = $1
          and site_name = $2
        group by 
            project_name, site_name
    """

    return await db.fetch_one(query, [collection_name, site_name])


@router.get("/{collection_name}/{site_name}/patients")
async def get_all_patients(collection_name: str, site_name: str, db: Database = Depends()):
    query = """
        select distinct 
            patient_name as patient 
        from ctp_file 
        natural join file_patient 
        where project_name = $1
          and site_name = $2
    """

    return await db.fetch(query, [collection_name, site_name])

@router.get("/{collection_name}/{site_name}/patients/{patient_id}")
async def get_single_patient(collection_name: str, site_name: str, patient_id: str, db: Database = Depends()):
    query = """
        select
            patient_name as patient,
            max(patient_id) as patient_id,
            max(sex) as patient_sex,
            max(ethnic_group) as patient_ethnic_group,
            array_agg(distinct comments) as comments,
            count(file_id) as file_count,
            count(distinct study_instance_uid) as study_count
        from ctp_file 
        natural join file_patient 
        natural join file_study
        where project_name = $1
          and site_name = $2
          and patient_name = $3
        group by patient_name
    """

    return await db.fetch_one(query, [collection_name, site_name, patient_id])

@router.get("/{collection_name}/{site_name}/patients/{patient_id}/studies")
async def get_all_studies(collection_name: str, site_name: str, patient_id: str, db: Database = Depends()):
    query = """
        select distinct 
            project_name as collection,
            site_name as site,
            patient_name as patient,
            study_instance_uid
        from ctp_file 
        natural join file_patient 
        natural join file_study
        where project_name = $1
          and site_name = $2
          and patient_name = $3
    """

    return await db.fetch(query, [collection_name, site_name, patient_id])
