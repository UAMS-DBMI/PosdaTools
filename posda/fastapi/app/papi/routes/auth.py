from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from starlette.status import HTTP_401_UNAUTHORIZED

fake_users_db = {
    "johndoe": {
        "username": "johndoe",
        "full_name": "John Doe",
        "email": "johndoe@example.com",
        "hashed_password": "fakehashedsecret",
        "disabled": False,
    },
    "alice": {
        "username": "alice",
        "full_name": "Alice Wonderson",
        "email": "alice@example.com",
        "hashed_password": "fakehashedsecret2",
        "disabled": True,
    },
}

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

def fake_hash_password(password: str):
    return "fakehashed" + password


class User(BaseModel):
    username: str
    email: str = None
    full_name: str = None
    disabled: bool = None


# Extend the User object to add a field
class UserInDB(User):
    hashed_password: str


def get_user(db, username: str):
    if username in db:
        user_dict = db[username]
        return UserInDB(**user_dict)


def fake_decode_token(token):
    # This doesn't provide any security at all
    # Check the next version
    user = get_user(fake_users_db, token)
    return user


async def get_current_user(token: str = Depends(oauth2_scheme)):
    user = fake_decode_token(token)
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


@router.post("/token")
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Here we should make a token, and store it in Redis with an expire
    # then extend the expire every time it is retrieved?

    # test if this user exists
    # TODO: this should be checking against the real db
    user_dict = fake_users_db.get(form_data.username)

    # fail if the user didn't exist
    if not user_dict:
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    # instantiate the user (this is a subclass of User, see above)
    user = UserInDB(**user_dict)

    # hash the supplied password
    # TODO: make this some real hashing, whatever Posda currently uses?
    # TODO: go figure out what posda is currently using and replicate here
    hashed_password = fake_hash_password(form_data.password)

    # fail if the password was wrong
    if not hashed_password == user.hashed_password:
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    # return a token if everything was good
    # TODO: this needs to create a true random token here (maybe just a UUID)
    # TODO: the token also must be inserted into Redis, with the username,
    # TODO: and an expiration date
    return {"access_token": user.username, "token_type": "bearer"}


@router.get("/users/me")
async def read_users_me(current_user: User = Depends(get_current_active_user)):
    return current_user

@router.get("/test")
async def testpoint():
    return {"message":"everything looks good"}


logged_in_user = Depends(get_current_active_user)
