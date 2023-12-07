from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse
from .auth import logged_in_user, User
from ..util import Database, asynctar
import mimetypes
import logging
import asyncio


router = APIRouter(
    tags=["Downloads"],
)


@router.get("/file/{downloadable_file_id}/{hash}") 
async def download_file(downloadable_file_id: int,
                        hash: str,
                        process: bool = False,
                        db: Database = Depends()):

    query = """
        select
            root_path || '/' || rel_path as file, 
            size,
            mime_type
        from downloadable_file
        natural join file
        natural join file_location 
        natural join file_storage_root
        where downloadable_file_id = $1
          and security_hash = $2
          and (valid_until is null or now() < valid_until)
    """

    records = await db.fetch(query, [downloadable_file_id, hash])

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.info(f"Invalid request: {downloadable_file_id}/{hash}")
        raise HTTPException(detail="no records returned", status_code=404)

    path = record['file']
    mime_type = record['mime_type']

    ext = mimetypes.guess_extension(mime_type)

    if process:
        proc = await asyncio.create_subprocess_shell(
            # f"/home/posda/posdatools/phimacro/phimacro.py {path}",
            f"/home/posda/posdatools/phimacro/run.sh {path}",
            # f"pwd",
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await proc.communicate()

        output = stdout.decode() + stderr.decode()

        return Response(content=output, media_type=mime_type)

    return FileResponse(path, filename=f"downloaded_file_{downloadable_file_id}{ext}")

@router.get('/dir/{downloadable_dir_id}/{hash}')
async def download_dir(downloadable_dir_id: int, hash: str, db: Database = Depends()):
    query = """
        select
            path
        from downloadable_dir
        where downloadable_dir_id = $1
          and security_hash = $2
    """

    records = await db.fetch(query, [downloadable_dir_id, hash])

    try:
        record = records[0]
    except IndexError:
        logging.debug("Query returned no results. Query follows:")
        logging.debug(query)
        logging.info(f"Invalid request: {downloadable_dir_id}/{hash}")
        raise HTTPException(detail="no records returned", status_code=404)


    path = record['path']

    return asynctar.stream_directory(
        path,
        f"downloaded_dir_{downloadable_dir_id}.tar.gz"
    )
