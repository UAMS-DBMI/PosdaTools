#!/usr/bin/env python3.6

import os
import logging
from sanic import Sanic

from papi.util import db
from papi.resources import tests, download, dump
import papi.blueprints

app = Sanic()

# Configure main routes
papi.blueprints.configure_blueprints(app)

# Add secondary routes
app.blueprint(tests.blueprint, url_prefix='/v1/tests')
app.blueprint(download.blueprint, url_prefix='/v1/download')
app.blueprint(dump.blueprint, url_prefix='/v1/dump')

# Deprecated routes
app.add_route(download.download_file, '/file/<downloadable_file_id>/<hash>')
app.add_route(download.download_dir, '/dir/<downloadable_dir_id>/<hash>')


@app.listener('before_server_start')
async def connect_to_db(sanic, loop):
    await db.setup(database='posda_files')

if __name__ == "__main__":

    debug = os.environ.get('DEBUG', 0) != 0
    host = os.environ.get('HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', '8087'))
    workers = int(os.environ.get('WORKERS', 4))

    if debug:
        logging.basicConfig(level=logging.DEBUG)
    else:
        logging.basicConfig(level=logging.INFO)

    logging.info('Starting up...')

    app.run(host=host, port=port, debug=debug, workers=workers)
