import asyncpg

pool = None

async def setup(*args, **kwargs):
    global pool
    pool = await asyncpg.create_pool(*args, **kwargs)
