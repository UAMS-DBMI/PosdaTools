import asyncpg
from sanic.exceptions import NotFound

pool = None

async def setup(*args, **kwargs):
    global pool
    pool = await asyncpg.create_pool(*args, **kwargs)


async def fetch(query, parameters=[]):
    global pool
    async with pool.acquire() as conn:
        print("\nfetching\n")
        records = await conn.fetch(query, *parameters)
        if len(records) < 1:
            raise NotFound("no matching records found")
        print("records:\n")
        print(dict(records[0]))
        return records

async def fetch_with_empty(query, parameters=[]):
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


# TODO: probably need to get rid of this?
async def fetch_as_objects(obj_type, query, parameters=[]):
    global pool
    async with pool.acquire() as conn:
        records = await conn.fetch(query, *parameters)
        print(dict(records[0]))
        return [obj_type(*r) for r in records]
