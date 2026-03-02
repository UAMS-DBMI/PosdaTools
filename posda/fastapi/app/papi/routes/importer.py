"""
This module handles importing files into Posda.
Import operations do not require a logged in user
"""
from fastapi import Depends, APIRouter, HTTPException
from starlette.requests import Request

from ..util import Database
from ..util.digest import md5sum_file

import hashlib
import tempfile
import os

router = APIRouter(
    tags=["Import"],
)

# These are default values; they should be configured
# from whatever code imports this module!
FILE_STORAGE_PATH = "/home/posda/cache/created"
TEMP_STORAGE_PATH = "/home/posda/cache/temp"
FILE_STORAGE_ROOT = 3

ROOT_MAP_CACHE = None


@router.put("/event")
async def import_event(
    source: str,
    origin: str = None,
    expected_count: int = None,
    db: Database = Depends(),
):
    """Create a new import event.

    Import events are a way to group individual file imports together.

    Args:
        source (str): A human-readable comment.
        origin (str, optional): The source or origin of the files.
        expected_count (int, optional): How many files you have to import,
                                        if known.
    """
    # NOTE: source was mistakenly named but is kept for backwards
    #       compatibility.
    # In reality, source = import_comment
    #             origin = actual source of the import
    pool = db.get_pool()

    async with pool.acquire() as conn:
        import_event_id = await create_import_event(conn, source, origin, expected_count)

        return {
            "status": "success",
            "import_event_id": import_event_id,
        }


@router.post("/event/{import_event_id}/close")
async def close_import_event(import_event_id: int, db: Database = Depends()):
    """Close an import event, by setting it's import_close_time to now.
    """
    record = await db.fetch_one(
        """\
        update import_event
        set import_close_time = now()
        where import_event_id = $1
        returning import_event_id
    """,
        [import_event_id],
    )

    if len(record) < 1:
        raise HTTPException(detail="invalid import_event_id", status_code=422)

    return {
        "status": "success",
    }

@router.post("/test")
async def import_test(db: Database = Depends()):
    pool = db.get_pool()

    async with pool.acquire() as conn:
        async with conn.transaction():
            computed_digest = 'bogus1'
            bytes_read = 37

            created, file_id = await create_or_get_file_id(computed_digest, bytes_read, conn)
            print(created, file_id)

            # await conn.execute("""\
            #     insert into file (digest) values ('bob')
            # """)
            # # this one should fail due to duplicate digest
            # await conn.execute("""\
            #     insert into file (digest) values ('bob')
            # """)


    return "Success"

@router.put("/file")
@router.post("/file")
async def import_file(
    request: Request,
    digest: str,
    import_event_id: int = None,
    localpath: str = None,
    subprocess_invocation_id: int = None,
    from_file_digest: str = None,
    db: Database = Depends(),
):
    """Import a single file.

    Both POST and PUT are accepted for legacy reasons.

    The request body must be the bytes of the file to submit.

    If subprocess_invocation_id AND from_file_digest are given,
    a link will be made (via dicom_edit_compare) to indicate the
    origin of this file.
    """
    # Read the submitted bytes from the request, to a temp file,
    # calculating the md5sum as we go.
    fp = tempfile.NamedTemporaryFile(dir=TEMP_STORAGE_PATH, delete=False)
    m = hashlib.md5(usedforsecurity=False)
    bytes_read = 0
    async for chunk in request.stream():
        m.update(chunk)
        fp.write(chunk)
        bytes_read += len(chunk)

    fp.close()

    computed_digest = m.hexdigest()
    if computed_digest != digest:
        os.unlink(fp.name)
        raise HTTPException(
            detail="digest of received bytes does not match supplied digest",
            status_code=422,
        )

    # Using pool directly here, so we can use a single transaction
    # for all of the following queries. This is an attempt to prevent
    # an issue where a file_id gets created, but the file doesn't actually
    # get saved, or the file_location record does not get created
    pool = db.get_pool()

    async with pool.acquire() as conn:
        async with conn.transaction():

            created, file_id = await create_or_get_file_id(computed_digest, bytes_read, conn)

            if created:
                root_id, root, rel_path = await copy_file_into_place(fp.name, computed_digest)

                await create_file_location(file_id, root_id, rel_path, conn)

                await make_ready_to_process(file_id, conn)

            else:
                os.unlink(fp.name)

            if import_event_id is None:
                import_event_id = await create_import_event(conn, "single-file api import")

            await create_file_import(file_id, int(import_event_id), localpath, conn)

            if subprocess_invocation_id is not None and from_file_digest is not None:
                await conn.execute("""\
                    insert into dicom_edit_compare
                    values ($1, $2, 0, 0, null, $3)
                """, from_file_digest, digest, subprocess_invocation_id)

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
        roots = await db.fetch(
            """\
            select * from file_storage_root
            order by file_storage_root_id
        """
        )

        root_map = {}
        for root in roots:
            root_map[root["root_path"]] = root["file_storage_root_id"]

        ROOT_MAP_CACHE = root_map

    return ROOT_MAP_CACHE


def find_best_root(root_map, path):
    """Find the best possible storage root for the path

    Collects all possible roots, and then returns the longest one.
    """

    possible_roots = []

    for r in root_map:
        if path.startswith(r):
            root = root_map[r]
            rel_path = path[len(r) + 1 :]
            root_len = len(path) - len(rel_path)
            possible_roots.append((root_len, root, rel_path))

    if len(possible_roots) < 1:
        raise HTTPException(detail="no matching file_storage_root", status_code=422)

    best_root = sorted(possible_roots, reverse=True, key=lambda x: x[0])[0]

    _, root_id, rel_path = best_root
    return (root_id, rel_path)


@router.post("/file_in_place")
async def import_file_in_place(
    request: Request,
    localpath: str,
    import_event_id: int = None,
    skip_processing: bool = False,
    digest: str = None,
    db: Database = Depends(),
):
    root_map = await get_root_map(db)

    match_root, rel_path = find_best_root(root_map, localpath)

    try:
        # If digest was supplied, skip calcaulting it, but we still
        # need to get the size
        if digest is not None:
            stat = os.stat(localpath)
            size = stat.st_size
        else:
            size, digest = md5sum_file(localpath)
    except FileNotFoundError:
        raise HTTPException(detail="no such file", status_code=422)

    pool = db.get_pool()

    async with pool.acquire() as conn:
        async with conn.transaction():

            created, file_id = await create_or_get_file_id(digest, size, conn)

            if created:
                await create_file_location(file_id, match_root, rel_path, conn)
                if not skip_processing:
                    await make_ready_to_process(file_id, conn)
                else:
                    await make_not_ready_to_process(file_id, conn)

            if import_event_id is None:
                import_event_id = await create_import_event(
                    conn, "single-file in-place api import"
                )

            await create_file_import(file_id, int(import_event_id), localpath, conn)

            return {
                "status": "success",
                "size": size,
                "digest": digest,
                "file_id": file_id,
                "created": created,
            }


async def create_import_event(conn, comment, origin=None, expected_count=None):
    record = await conn.fetchrow(
        """\
        insert into import_event
        (import_type, import_comment, import_time, import_origin, import_expected_count)
        values
        ($1, $2, now(), $3, $4)
        returning import_event_id
    """,
        *["posda-api import", comment, origin, expected_count],
    )

    return record["import_event_id"]


async def copy_file_into_place(filename: str, digest: str):
    # figure out what file_storage_root_id is
    root_id = FILE_STORAGE_ROOT
    root = FILE_STORAGE_PATH
    path = os.path.join(digest[:2], digest[2:4], digest[4:6])

    rel_path = os.path.join(path, digest)

    # The full path on disk, exlcuding the actual filename
    real_path = os.path.join(root, path)
    if not os.path.exists(real_path):
        os.makedirs(real_path)

    os.rename(filename, os.path.join(root, rel_path))
    return root_id, root, rel_path


async def make_ready_to_process(file_id: int, conn):
    await conn.fetch(
        """\
        update file
        set ready_to_process = true
        where file_id = $1
    """,
        *[file_id],
    )


async def make_not_ready_to_process(file_id: int, conn):
    await conn.fetch(
        """\
        update file
        set ready_to_process = false
        where file_id = $1
    """,
        *[file_id],
    )


async def create_file_location(file_id, root_id, rel_path, conn):
    await conn.fetch(
        """\
        insert into file_location
        (file_id, file_storage_root_id, rel_path)
        values
        ($1, $2, $3)
    """,
        *[file_id, root_id, rel_path],
    )


async def create_file_import(
    file_id: int, import_event_id: int, localpath: str, conn
):
    await conn.fetch(
        """\
        insert into file_import
        values
        ($1, $2, $3, $4, $5, now())
    """,
        *[import_event_id, file_id, None, None, localpath],
    )


async def create_or_get_file_id(digest: str, size: int, conn):
    created = True
    record = await conn.fetchrow(
        """\
        insert into file
        (digest, size, processing_priority)
        values
        ($1, $2, 1)
        on conflict do nothing
        returning file_id
    """,
        *[digest, size],
    )

    if record is None:
        # the file already exists, so get the file_id
        record = await conn.fetchrow(
            """\
            select file_id
            from file
            where digest = $1
        """,
            *[digest],
        )
        created = False

    file_id = record["file_id"]

    return (created, file_id)
