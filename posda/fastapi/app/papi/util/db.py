import asyncpg
from asyncpg.exceptions import UniqueViolationError

pool = None
database = 'posda_files'

class NotFound(RuntimeError): pass

class Database:
    def __init__(self):
        pass

    async def execute(self, query, parameters=[]):
        global pool

        async with pool.acquire() as conn:
            return await conn.execute(query, *parameters)

    async def fetch(self, query, parameters=[]):
        global pool
        # if pool is None:
        #     await setup(database=database)

        async with pool.acquire() as conn:
            records = await conn.fetch(query, *parameters)
            return records


    async def fetch_one(self, query, parameters=[]):
        """Execute query and return only the first result

        Raises NotFound if the query returns no matches
        """
        global pool
        # if pool is None:
        #     await setup(database=database)

        async with pool.acquire() as conn:
            records = await conn.fetch(query, *parameters)
            if len(records) < 1:
                return []
                # raise NotFound("no matching records found")
            return records[0]


    

async def setup(*args, **kwargs):
    global pool
    pool = await asyncpg.create_pool(*args, **kwargs)


async def fetch(query, parameters=[]):
    global pool
    async with pool.acquire() as conn:
        records = await conn.fetch(query, *parameters)
        return records


async def fetch_one(query, parameters=[]):
    """Execute query and return only the first result

    Raises NotFound if the query returns no matches
    """
    global pool
    async with pool.acquire() as conn:
        records = await conn.fetch(query, *parameters)
        if len(records) < 1:
            raise NotFound("no matching records found")
        return records[0]


