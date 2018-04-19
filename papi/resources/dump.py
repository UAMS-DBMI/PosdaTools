script_location = '/posda-api/dicom_dump.sh'

from sanic.response import text, HTTPResponse
from sanic import Blueprint
import asyncio
import logging

from ..util import db


blueprint = Blueprint('dump', url_prefix='/dump')


async def dump_dicom(request, file_id):
    # get the filename from the database
    logging.debug(f"Generating dump for {file_id}")
    query = """
        select root_path || '/' || rel_path as file
        from
            file_location
            natural join file_storage_root
        where file_id = $1
    """

    async with db.pool.acquire() as conn:
        records = await conn.fetch(query, file_id)

    try:
        file = records[0]['file']
        logging.debug(file)
    except IndexError:
        return HTTPResponse(status=404)

    try:
        logging.debug(asyncio.subprocess.PIPE)
        proc = await asyncio.create_subprocess_exec(
            script_location, file, stdout=asyncio.subprocess.PIPE)
    except Exception as e:
        logging.error("Failed to create subprocess")
        logging.error(e)
        raise e
        return text("Dump failed", status=500)

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

    return text(new_data)


blueprint.add_route(dump_dicom, '/<file_id:int>')
