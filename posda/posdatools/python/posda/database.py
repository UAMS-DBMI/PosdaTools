from contextlib import ContextDecorator, contextmanager

import psycopg2
from psycopg2.extras import NamedTupleCursor
import mysql.connector

from .config import Config


DB_CONFIG = None
POOL = {}
MYPOOL = {}

def flush_pool():
    """Close all connections in the connection pool.

    This is useful just before forking"""
    global POOL, MYPOOL
    for i, conn in POOL.items():
        try:
            conn.close()
        except:
            pass
    POOL = {}

    for i, conn in MYPOOL.items():
        try:
            conn.close()
        except:
            pass
    MYPOOL = {}


def Database(name):
    # get the dsn from the config
    global DB_CONFIG
    if DB_CONFIG is None:
        DB_CONFIG = Config.load_db_config()

    try:
        # locate the actual name of the given database
        dsn = DB_CONFIG[name]
    except KeyError:
        # TODO: add logging module
        print(f"Warning: There is no configured database {name}, "
               "assuming you want a direct connection to postgres.")
        dsn = dict(database=name, driver='postgres')

    # decide which DB type to spawn
    if dsn['driver'] == 'postgres':
        return PostgresDatabase(dsn)

    if dsn['driver'] == 'mysql':
        return MysqlDatabase(dsn)

    raise KeyError(f"Unknown driver type: {dsn['driver']}")

class BaseDatabase(ContextDecorator):
    def connection(self):
        raise NotImplementedError()

    def __enter__(self):
        return self.connection()

    def __exit__(self, *args):
        return False

    def cursor(self):
        return self.connection().cursor()

class MysqlDatabase(BaseDatabase):
    def __init__(self, dsn):
        self.dsn = dict(dsn)
        del self.dsn['driver']
        self.name = self.dsn['database']

    def __str__(self):
        return f"<posda.database.MysqlDatabase: {self.name}>"

    def _get_connection_from_pool(self, dbname):
        if dbname not in MYPOOL:
            MYPOOL[dbname] = mysql.connector.connect(**self.dsn)
            MYPOOL[dbname].autocommit = True

        return MYPOOL[dbname]

    def connection(self):
        return self._get_connection_from_pool(self.dsn['database'])

    def cursor(self):
        return self.connection().cursor(named_tuple=True)


class PostgresDatabase(BaseDatabase):
    def __init__(self, dsn):
        self.dsn = dsn
        self.name = dsn['database']

    def __str__(self):
        return f"<posda.database.PostgresDatabase: {self.name}>"

    def _get_connection_from_pool(dbname):
        if dbname not in POOL:
            POOL[dbname] = psycopg2.connect(
                # TODO: this needs to handle the full dsn!
                f"dbname={dbname}", 
                cursor_factory=NamedTupleCursor)
            POOL[dbname].autocommit = True

        return POOL[dbname]


    def connection(self):
        self._connection = \
            PostgresDatabase._get_connection_from_pool(self.dsn['database'])

        return self._connection



