#!/usr/bin/env python3.6

import os
import logging
from sanic import Sanic

from papi.util import db
from papi.resources import tests, download, dump, importer
import papi.blueprints

app = Sanic()

# Configure main routes
papi.blueprints.configure_blueprints(app)

# Add secondary routes
app.blueprint(tests.blueprint, url_prefix='/v1/tests')
app.blueprint(download.blueprint, url_prefix='/v1/download')
app.blueprint(dump.blueprint, url_prefix='/v1/dump')

# Deprecated routes
app.add_route(download.download_file, '/file/<downloadable_file_id>/<hash>', stream=True)
# WARNING !!! WARNING !!! WARNING !!! WARNING !!! WARNING !!! WARNING !!!
# The `stream=True` above is unused by the deprecated downloadable_file
# route, HOWEVER it is necessary because of a bug which is preventing
# blueprints from imported files from having stream support.
# I cannot figure out why, but as long as one route added directly
# to the app instance has stream set to True, all other streaming functions
# work. So, don't remove that line. If the time comes when you need to
# retire the deprecated route, you will have to find another top-level
# route to add stream=True to. Or, check to see if the bug has been fixed.
# The bug is present in Sanic==18.12.0
app.add_route(download.download_dir, '/dir/<downloadable_dir_id>/<hash>')



@app.listener('before_server_start')
async def connect_to_db(sanic, loop):
    await db.setup(database='posda_files')

if __name__ == "__main__":

    debug = os.environ.get('DEBUG', 0) != 0
    host = os.environ.get('HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', '8087'))
    workers = int(os.environ.get('WORKERS', 4))


    # configure importer
    importer.FILE_STORAGE_PATH = os.environ.get(
        'FILE_STORAGE_PATH',
        "/home/posda/cache/created" 
    )
    importer.TEMP_STORAGE_PATH = os.environ.get(
        'TEMP_STORAGE_PATH',
        "/home/posda/temp"
    )
    importer.FILE_STORAGE_ROOT = int(os.environ.get(
        'FILE_STORAGE_ROOT',
        3
    ))


    if debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    logging.info('Starting up...')

    app.config.REQUEST_MAX_SIZE = 15 * 1024 * 1024 * 1024 # 15GiB
    app.config.REQUEST_TIMEOUT = 10 * 60 * 60 # 10 minutes

    app.run(host=host, port=port, debug=debug, workers=workers)
