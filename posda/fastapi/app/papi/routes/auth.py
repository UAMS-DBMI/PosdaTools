from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from starlette.status import HTTP_401_UNAUTHORIZED
import uuid

from ..util import Database
from ..util.password import is_valid
from ..util.redisqueue import get_redis_connection

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/papi/auth/token")

TOKEN_EXPIRE=(1 * 60 * 60) # 1 hour

class User(BaseModel):
    user_id: int
    username: str
    full_name: str = None
    disabled: bool = None

# Extend the User object to add a field
class UserInDB(User):
    hashed_password: str

async def get_user(db, username: str):
    user_dict = await get_user_from_database(db, username)
    if user_dict:
        return User(**user_dict)


async def decode_token(db, token):
    redis_db = get_redis_connection()
    
    username = redis_db.get(token)
    if username is None:
        return None

    redis_db.expire(token, TOKEN_EXPIRE)

    user = await get_user(db, username)
    return user


async def get_current_user(token: str = Depends(oauth2_scheme),
                           db: Database = Depends()):
    user = await decode_token(db, token)
    if not user:
        raise HTTPException(
            status_code=HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


async def get_current_active_user(current_user: User = Depends(get_current_user)):
    if current_user.disabled:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

async def get_user_from_database(db: Database, username: str):
    query = """
        select
            user_id,
            user_name as username,
            full_name,
            password as hashed_password,
            disabled
        from auth.users
        where user_name = $1
    """

    return await db.fetch_one(query, [username])

@router.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends(),
                db: Database = Depends()):
    # Here we should make a token, and store it in Redis with an expire
    # then extend the expire every time it is retrieved?

    redis_db = get_redis_connection()

    # retrieve this user from the database
    user_dict = await get_user_from_database(db, form_data.username)

    # fail if the user didn't exist
    if not user_dict:
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    # instantiate the user (this is a subclass of User, see above)
    user = UserInDB(**user_dict)

    # fail if the password was wrong
    # if not hashed_password == user.hashed_password:
    if not is_valid(user.hashed_password, form_data.password):
        raise HTTPException(status_code=400,
                            detail="Incorrect username or password")

    # return a token if everything was good
    access_token = str(uuid.uuid4())

    # add the token to reids with an expiration (to auto log out)
    redis_db.set(access_token, user.username, ex=TOKEN_EXPIRE)

    return {"access_token": access_token, "token_type": "bearer"}


# These are just test functions
@router.get("/users/me")
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@router.get("/test")
async def testpoint():
    return {"message":"everything looks good"}

# TODO: do we really want this here?
logged_in_user = Depends(get_current_active_user)
