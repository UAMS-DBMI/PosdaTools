from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse
from starlette.requests import Request
from .auth import logged_in_user, User

from ..util import Database, asynctar, roi
from ..util.digest import md5sum_file

router = APIRouter()

import hashlib
import tempfile
import os

# TODO delete this
class HTTPMethodView: pass



# These are default values; they should be configured
# from whatever code imports this module!
FILE_STORAGE_PATH = "/home/posda/cache/created"
TEMP_STORAGE_PATH = "/home/posda/cache/temp"
FILE_STORAGE_ROOT = 3

ROOT_MAP_CACHE = None

@router.put("/event")
async def import_event(source: str, origin: str = None, expected_count: int = None, db: Database = Depends()):
    # NOTE: source was mistakenly named but is kept for backwards
    #       compatibility.
    # In reality, source = import_comment
    #             origin = actual source of the import
    import_event_id = await create_import_event(db, source, origin, expected_count)

    return {
        'status': 'success',
        'import_event_id': import_event_id,
    }

@router.post("/event/{import_event_id}/close")
async def close_import_event(import_event_id: int, db: Database = Depends()):
    record = await db.fetch_one("""\
        update import_event
        set import_close_time = now()
        where import_event_id = $1
        returning import_event_id
    """, [import_event_id])

    if len(record) < 1:
        raise HTTPException(detail="invalid import_event_id", status_code=422)

    return {
        'status': 'success',
    }


@router.put("/file")
@router.post("/file")
async def import_file(request: Request, digest: str, import_event_id: int = None, localpath: str = None, db: Database = Depends()):
    fp = tempfile.NamedTemporaryFile(dir=TEMP_STORAGE_PATH, delete=False)
    m = hashlib.md5()
    bytes_read = 0
    async for chunk in request.stream():
        m.update(chunk)
        fp.write(chunk)
        bytes_read += len(chunk)

    fp.close()

    computed_digest = m.hexdigest()
    if computed_digest != digest:
        os.unlink(fp.name)
        raise HTTPException(detail="digest of received bytes does not match "
                           "supplied digest", status_code=422)


    created, file_id = \
        await create_or_get_file_id(computed_digest, bytes_read, db)

    if created:
        root_id, root, rel_path = \
            await copy_file_into_place(fp.name, computed_digest)

        await create_file_location(file_id, root_id, rel_path, db)

        await make_ready_to_process(file_id, db)

    else:
        os.unlink(fp.name)


    if import_event_id is None:
        import_event_id = await create_import_event(db, 'single-file api import')

    await create_file_import(file_id, int(import_event_id), localpath, db)

    return {
        "status": "success",
        "size": bytes_read,
        "digest": computed_digest,
        "file_id": file_id,
        "created": created,
    }

async def get_root_map(db: Database):
    """Return the map of File Storage Roots. Cache when possible"""
    global ROOT_MAP_CACHE

    if ROOT_MAP_CACHE is None:
        roots = await db.fetch("""\
            select * from file_storage_root
        """)

        root_map = {}
        for root in roots:
            root_map[root['root_path']] = root['file_storage_root_id']

        ROOT_MAP_CACHE = root_map

    return ROOT_MAP_CACHE

@router.post("/file_in_place")
async def import_file_in_place(request: Request,
                               import_event_id: int,
                               localpath: str,
                               db: Database = Depends()):

    root_map = await get_root_map(db)

    match_root = None
    rel_path = None
    for r in root_map:
        if localpath.startswith(r):
            match_root = root_map[r]
            rel_path = localpath[len(r)+1:]
    if match_root is None:
        raise HTTPException(detail="no matching file_storage_root", status_code=422)


    try:
        size, digest = md5sum_file(localpath)
    except FileNotFoundError:
        raise HTTPException(detail="no such file", status_code=422)

    created, file_id = \
        await create_or_get_file_id(digest, size, db)

    if created:
        await create_file_location(file_id, match_root, rel_path, db)
        await make_ready_to_process(file_id, db)

    await create_file_import(file_id, int(import_event_id), localpath, db)

    return {
        "status": "success",
        "size": size,
        "digest": digest,
        "file_id": file_id,
        "created": created,
    }

async def create_import_event(db, comment, origin = None, expected_count = None):
    record = await db.fetch_one("""\
        insert into import_event
        (import_type, import_comment, import_time, import_origin, import_expected_count)
        values
        ($1, $2, now(), $3, $4)
        returning import_event_id
    """, ['posda-api import', comment, origin, expected_count])

    return record['import_event_id']


async def copy_file_into_place(filename: str, digest: str):
    # figure out what file_storage_root_id is
    root_id = FILE_STORAGE_ROOT
    root = FILE_STORAGE_PATH
    path = os.path.join(digest[:2],
                        digest[2:4],
                        digest[4:6])

    rel_path = os.path.join(path, digest)

    # The full path on disk, exlcuding the actual filename
    real_path = os.path.join(root, path)
    if not os.path.exists(real_path):
        os.makedirs(real_path)

    os.rename(filename, os.path.join(root, rel_path))
    return root_id, root, rel_path

async def make_ready_to_process(file_id: int, db: Database):
    await db.fetch("""\
        update file
        set ready_to_process = true
        where file_id = $1
    """, [file_id])

async def create_file_location(file_id, root_id, rel_path, db: Database):
    await db.fetch("""\
        insert into file_location
        (file_id, file_storage_root_id, rel_path)
        values
        ($1, $2, $3)
    """, [file_id, root_id, rel_path])

async def create_file_import(file_id: int, import_event_id: int, localpath: str, db: Database):
    await db.fetch("""\
        insert into file_import
        values
        ($1, $2, $3, $4, $5, now())
    """, [import_event_id, file_id, None, None, localpath])

async def create_or_get_file_id(digest: str, size: int, db: Database):
    created = True
    record = await db.fetch_one("""\
        insert into file
        (digest, size, processing_priority)
        values
        ($1, $2, 1)
        on conflict do nothing
        returning file_id
    """, [digest, size])

    if len(record) < 1:
        # the file already exists, so get the file_id
        record = await db.fetch_one("""\
            select file_id
            from file
            where digest = $1
        """, [digest])
        created = False

    file_id = record['file_id']

    return (created, file_id)
