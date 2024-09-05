from fastapi import Depends, APIRouter, HTTPException
from starlette.requests import Request
from starlette.responses import PlainTextResponse, JSONResponse, Response
from pydantic import BaseModel
from typing import List
import datetime
from enum import Enum

from .auth import logged_in_user, User

from ..util import Database
from ..util import db as db_module
from asyncpg.exceptions import UniqueViolationError, InvalidTextRepresentationError

router = APIRouter(
    tags=["DICOM Roots Table"],
    dependencies=[logged_in_user]
)

@router.get("/")
async def get_all_roots():
    raise HTTPException(detail="test error", status_code=401)

class AccessType(str, Enum):
    public = "public"
    limited = "limited"


@router.get("/searchRoots")
async def search_roots(
    site_code: str = None,
    collection_code: str = None,
    site_name: str = None,
    collection_name: str = None,
    patient_id_prefix: str = None,
    body_part: str = None,
    access_type: AccessType = None,
    baseline_date: str = None,
    date_shift: str = None,
    db: Database = Depends()):
    """Search the roots (submissions) table using a variety of fields
    """


    whereclause = "where 1 = 1 "
    values = []
    pos = iter(range(1, 10))

    if site_code is not None:
        whereclause += f"and site_code like ${next(pos)} "
        values.append(site_code)

    if collection_code is not None:
        whereclause += f"and collection_code like ${next(pos)} "
        values.append(collection_code)

    if site_name is not None:
        whereclause += f"and site_name like ${next(pos)} "
        values.append(site_name)

    if collection_name is not None:
        whereclause += f"and collection_name like ${next(pos)} "
        values.append(collection_name)

    if patient_id_prefix is not None:
        whereclause += f"and patient_id_prefix like ${next(pos)} "
        values.append(patient_id_prefix)

    if body_part is not None:
        whereclause += f"and body_part like ${next(pos)} "
        values.append(body_part)

    if access_type is not None:
        whereclause += f"and access_type = ${next(pos)} "
        values.append(access_type)

    if baseline_date is not None:
        whereclause += f"and baseline_date::text like ${next(pos)} "
        values.append(baseline_date)

    if date_shift is not None:
        whereclause += f"and date_shift::text like ${next(pos)} "
        values.append(date_shift)


    query = """\
        select
        b.*,
        c.*,
        a.patient_id_prefix,
        a.body_part,
        a.access_type,
        a.baseline_date,
        a.date_shift,
        a.uid_root
        from
        	submissions a
        	natural join collection_codes b
        	natural join site_codes c
            {}
    """.format(whereclause)

    print(query, values)

    return await db.fetch(query, values)


@router.get("/findCollectionNameFromCode/{collection_code}")
async def find_collection_name_from_code(collection_code: int, db: Database = Depends()) -> PlainTextResponse:
    record = await db.fetch_one("""\
        select
         collection_name
        from
         collection_codes
        where
         collection_code = $1
        """, [str(collection_code)])
    return PlainTextResponse(record['collection_name'])


@router.get("/findSiteNameFromCode/{site_code}")
async def find_site_name_from_code(site_code: int, db: Database = Depends()) -> PlainTextResponse:
    record = await db.fetch_one("""\
       select
        site_name
       from
        site_codes
       where
        site_code = $1
       """, [str(site_code)])
    return PlainTextResponse(record['site_name'])



class Submission(BaseModel):
    input_site_code: int
    input_site_name: str
    input_collection_code: int
    input_collection_name: str
    input_patient_id_prefix: str
    input_body_part: str
    input_access_type: str
    input_baseline_date: str = None
    input_date_shift: str = None
    input_uid_root: str = None

    def for_query(self):
        """Return the 7 values needed for insert into the submissions table"""

        def toint(some_obj):
            if len(some_obj) < 1:
                return None
            else:
                return int(some_obj)

        baseline_date = self.input_baseline_date
        if len(baseline_date) < 1:
            baseline_date = None
        
        return (str(self.input_site_code),
                str(self.input_collection_code),
                self.input_patient_id_prefix,
                self.input_body_part,
                self.input_access_type,
                baseline_date,
                toint(self.input_date_shift),
                self.input_uid_root)


@router.post("/addNewSubmission")
async def add_new_submission(submission: Submission, db: Database = Depends()):
    # check if the site_code already exists
    record = await db.fetch_one("""\
        select
         site_name
        from
         site_codes
        where
         site_code = $1
        """, [str(submission.input_site_code)])

    if len(record) == 0:
        # add the site_code if it doesn't already exist
        try:
            print("inserting")
            await db.execute(
                "insert into site_codes (site_code, site_name) values ($1, $2)", 
                [str(submission.input_site_code), submission.input_site_name]
            )
        except UniqueViolationError:
            # This would be easier to just raise HTTPException, however the
            # frontend code expects the JSON response to be exactly this
            return JSONResponse(
                {'message': "Your site code or site name is already in use. Please choose a unique code and name \n"},
                status_code=422
            )
        except Exception as e:
            return JSONResponse(
                {'message': "An unexpected error occurred: \n" + str(e)},
                status_code=500
            )

    record = await db.fetch_one("""\
       select
        collection_name
       from
        collection_codes
       where
        collection_code = $1
       """, [str(submission.input_collection_code)])

    if len(record) == 0:
        try:
            await db.execute(
                "insert into collection_codes (collection_code, collection_name) values ($1, $2)",
                [str(submission.input_collection_code), str(submission.input_collection_name)]
            )
        except UniqueViolationError:
            # This would be easier to just raise HTTPException, however the
            # frontend code expects the JSON response to be exactly this
            return JSONResponse(
                {'message': "Your collection code or collection name is already in use. Please choose a unique code and name \n"},
                status_code=422
            )
        except Exception as e:
            return JSONResponse(
                {'message': "An unexpected error occurred: \n" + str(e)},
                status_code=500
            )

    try:
        # We need to overwrite the date type conversion, so we need
        # direct access to the connection object, so we do that here
        # Here the encoder is set to str, so that we bypass asyncpg's
        # automatic type conversion. PostgreSQL can handle converting
        # the string into a date without us having to turn it into a
        # python type first!
        async with db_module.pool.acquire() as conn:
            await conn.set_type_codec(
                'timestamp', encoder=str, decoder=str,
                schema='pg_catalog', format='text'
            )

            await conn.execute("""\
                insert
                    into submissions
                    (site_code, collection_code, patient_id_prefix,
                     body_part,access_type, baseline_date, date_shift, uid_root)
                    values
                    ($1, $2, $3, $4, $5, $6, $7, $8)""",
                    *(submission.for_query())
                )
    except UniqueViolationError:
        # This would be easier to just raise HTTPException, however the
        # frontend code expects the JSON response to be exactly this
        return JSONResponse(
            {'message':"\n Your entry is already in use. Please choose a unique site + collection."},
            status_code=422
        )
    except InvalidTextRepresentationError:
        return JSONResponse(
            {'message':"Access Type must be one of: public, limited"},
            status_code=422
        )


    return Response(status_code=201)
