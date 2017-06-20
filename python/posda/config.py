from contextlib import ContextDecorator, contextmanager
import psycopg2
from psycopg2.extras import NamedTupleCursor

import json
import os
from pprint import pprint


DEBUG = True

DB_CONFIG = None
POOL = {}


class Config(object):
    """Class that represents the current configuration state of Posda"""
    def get(option):
        option = option.upper()
        if not option.startswith("POSDA_"):
            option = "POSDA_" + option

        return os.environ.get(option, None)

    def load_db_config():
        global DB_CONFIG
        # TODO: figure out where the config file is
        file_location = Config.get("database_config") or \
            '/home/posda/PosdaTools/Config/databases.json'

        with open(file_location) as inf:
            db_config = json.load(inf)

        DB_CONFIG = db_config

class Database(ContextDecorator):
    def __str__(self):
        return f"<Database: {self.name}>"

    def _get_connection_from_pool(dbname):
        if dbname not in POOL:
            POOL[dbname] = psycopg2.connect(
                # TODO: this needs to handle the full dsn!
                f"dbname={dbname}", 
                cursor_factory=NamedTupleCursor)
            POOL[dbname].autocommit = True

        return POOL[dbname]

    def __init__(self, name):
        self.name = name
        if DB_CONFIG is None:
            Config.load_db_config()

        try:
            # locate the actual name of the given database
            self.dsn = DB_CONFIG[self.name]
        except KeyError:
            # TODO: add logging module
            print(f"Warning: There is no configured database {self.name}, "
                   "assuming you want a direct connection.")
            self.dsn = dict(database=self.name, driver='postgres')


    def __enter__(self):
        return self.connection()

    def __exit__(self, *exc):
        # self._connection.close()
        return False

    def connection(self):
        self._connection = \
            Database._get_connection_from_pool(self.dsn['database'])

        return self._connection


    def cursor(self):
        return self.connection().cursor()

