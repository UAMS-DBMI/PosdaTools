from fastapi import Depends, APIRouter, HTTPException
from starlette.requests import Request
from starlette.responses import StreamingResponse

router = APIRouter()

from .auth import logged_in_user, User
from ..util import asynctar

from io import BytesIO

@router.get("/streamtest")
async def stream_test():
    async def stream_fn():
        for i in range(50):
            yield bytes([1, 2, 3])

    return StreamingResponse(stream_fn(), media_type='application/octet-stream')

@router.get("/tar")
async def tar_test():
    test = BytesIO()

    async def stream_fn():
        for i in range(50):
            test.seek(0)  # Reset to start of buffer before writing data
            test.write(b"\xab\xcd\xde\xff")  # write some data
            test.write(bytes([i]))  # write the current count
            test.seek(0)  # seek to start before reading
            while True:
                b = test.read(5)
                if len(b) > 0:
                    yield b
                else:
                    break
            
    return StreamingResponse(stream_fn(), media_type='application/octet-stream')


@router.get("/asynctar")
async def asynctar_test():
    return asynctar.stream('/home/quasar/projects/NBIA-TCIA', 'somefile.tar.gz')

@router.get("/testme", response_model=User)
async def test_me(
    current_user: User = logged_in_user) -> User:

    user_dict = current_user.dict()
    user_dict['other'] = "some other stuff here"
    return user_dict

@router.get("/query/{query_name}/execute")
async def request_Test(query_name: str, request: Request):
    return {
        "query": query_name,
        "params": dict(request.query_params)
    }
