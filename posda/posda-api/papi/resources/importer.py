from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView, stream
from sanic.exceptions import NotFound, InvalidUsage

from ..util import db
from ..util import json_objects, json_records

import hashlib
import tempfile
import os

LOC = "/home/posda/cache/created" #TODO this should be read from db
# The temp dir MUST be on the same filesystem as the eventual location
# under this system!
TEMP_DIR = "/home/posda/temp"

class ImportEvent(HTTPMethodView):
    async def put(self, request):
        source = request.args.get('source')
        if source is None:
            raise InvalidUsage("source is required")

        import_event_id = await create_import_event(source)

        return json({
            'status': 'success',
            'import_event_id': import_event_id,
        })

class CloseImportEvent(HTTPMethodView):
    def post(self, request, event_id):
        # if int(event_id) != 328: # TODO fix this
        #     # not found path
        #     raise NotFound("no such import event found")


        return json({
            'status': 'success',
        })

class ImportFile(HTTPMethodView):
    @stream
    async def put(self, request):
        import_event_id = request.args.get('import_event_id')
        digest = request.args.get('digest')


        # if digest is None, that's okay

        fp = tempfile.NamedTemporaryFile(dir=TEMP_DIR, delete=False)
        m = hashlib.md5()
        bytes_read = 0
        while True:
            data = await request.stream.get()
            if data is None:
                break
            m.update(data)
            fp.write(data)
            bytes_read += len(data)

        computed_digest = m.hexdigest()
        if digest is not None and computed_digest != digest:
            raise InvalidUsage("digest of received bytes does not match "
                               "supplied digest")

        fp.close()

        created, file_id = \
            await create_or_get_file_id(computed_digest, bytes_read)

        if created:
            root_id, root, rel_path = \
                await copy_file_into_place(fp.name, computed_digest)

            await create_file_location(file_id, root_id, rel_path)

            await make_ready_to_process(file_id)

        else:
            os.unlink(fp.name)


        if import_event_id is None:
            import_event_id = await create_import_event('single-file api import')
            
        await create_file_import(file_id, int(import_event_id))

        return json({
            "status": "success",
            "size": bytes_read,
            "digest": computed_digest,
            "file_id": file_id,
            "created": created,
        })

async def create_import_event(comment):
    async with db.pool.acquire() as conn:
        record = await conn.fetchrow("""\
            insert into import_event
            (import_type, import_comment)
            values
            ($1, $2)
            returning import_event_id
        """, 'posda-api import', comment)

        return record['import_event_id']

async def copy_file_into_place(filename, digest):
    # figure out what file_storage_root_id is
    root_id = 3 #TODO fake
    root = LOC # fake
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

async def make_ready_to_process(file_id):
    async with db.pool.acquire() as conn:
        await conn.execute("""\
            update file
            set ready_to_process = true
            where file_id = $1
        """, file_id)

async def create_file_location(file_id, root_id, rel_path):
    async with db.pool.acquire() as conn:
        await conn.execute("""\
            insert into file_location
            (file_id, file_storage_root_id, rel_path)
            values
            ($1, $2, $3)
        """, file_id, root_id, rel_path)

async def create_file_import(file_id, import_event_id):
    async with db.pool.acquire() as conn:
        await conn.execute("""\
            insert into file_import
            values
            ($1, $2, $3, $4, $5)
        """, import_event_id, file_id, None, None, None)
        # TODO The 3 empty fields could be filled with something?

async def create_or_get_file_id(digest, size):
    created = True
    async with db.pool.acquire() as conn:
        record = await conn.fetchrow("""\
            insert into file
            (digest, size, processing_priority)
            values
            ($1, $2, 1)
            on conflict do nothing
            returning file_id
        """, digest, size)

        if record is None:
            # the file already exists, so get the file_id
            record = await conn.fetchrow("""\
                select file_id
                from file
                where digest = $1
            """, digest)
            created = False
        
        file_id = record['file_id']

        return (created, file_id)