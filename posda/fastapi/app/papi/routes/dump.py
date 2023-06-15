# this is a hard coded value that will probably only work inside 
# the intended docker container
script_location = '/fastapi/dump_dicom.sh'

from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse, HTMLResponse

from .auth import logged_in_user, User
from ..util import Database

import asyncio
import logging

router = APIRouter(
    tags=["DICOM Dump"],
    dependencies=[logged_in_user],
    responses={
        401:  {"description": "User is not logged in"},
    }
)

@router.get(
    "/{file_id}",
    response_class=HTMLResponse,
    responses={
        404:  {"description": "The file_id was not found/invalid"},
    }
)
async def dump_dicom(file_id: int, db: Database = Depends()) -> HTMLResponse:
    """
    Returns an HTML-formatted DICOM Dump of the given file_id,
    if it is a DICOM file.

    The resulting dump is decoded as utf8 if possible, and if not
    the correct encoding is guessed by chardet.
    """

    # get the filename from the database
    logging.debug(f"Generating dump for {file_id}")
    query = """
        select root_path || '/' || rel_path as file
        from
            file_location
            natural join file_storage_root
        where file_id = $1
    """

    records = await db.fetch(query, [file_id])

    try:
        file = records[0]['file']
        logging.debug(file)
    except IndexError:
        raise HTTPException(detail=f"file_id {file_id} does not exist", status_code=404)

    try:
        proc = await asyncio.create_subprocess_exec(
            script_location, file, stdout=asyncio.subprocess.PIPE)
    except Exception as e:
        logging.error("Failed to create subprocess")
        logging.error(e)
        raise e

    logging.debug("process created, about to wait on it")

    # await proc.wait() # wait for it to end
    # logging.debug("process ended, getting data")
    data = await proc.stdout.read()  # read entire output
    logging.debug("data got, returning it")

    try:
        new_data = data.decode()
    except UnicodeDecodeError:
        # Guess at the encoding
        import chardet
        encoding = chardet.detect(data)['encoding']
        new_data = data.decode(encoding)

    return HTMLResponse(new_data)
