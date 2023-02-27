import os
import redis

CONNECTION = None

REDIS_HOST = os.environ.get(
    'POSDA_REDIS_HOST',
    "redis"
)

def connect_to_redis():
    redis_db = redis.StrictRedis(
        host=REDIS_HOST,
        db=1,  # using db #1 to keep login tokens separate from other data
        decode_responses=True
    )

    return redis_db

def get_redis_connection():
    global CONNECTION

    if CONNECTION is None:
        CONNECTION = connect_to_redis()

    # Try to reconnect if the connection has expired
    try:
        CONNECTION.ping()
    except redis.ConnectionError:
        CONNECTION = connect_to_redis()

    return CONNECTION
