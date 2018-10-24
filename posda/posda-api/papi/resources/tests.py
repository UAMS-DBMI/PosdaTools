from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView
from sanic import Blueprint

from ..util import asynctar
from ..util import db


blueprint = Blueprint('tests', url_prefix='/tests')

async def list_tests(request):
    return json({
        'tests_available': [
            'main',
            'full',
            'tar',
            'db',
        ]
    })

# A simple example of a class-based view
# custom verbs are not supported (at least not in this way)
class Test(HTTPMethodView):
    async def get(self, request):
        return text("test passed")

    async def post(self, request):
        return text("post test passed")

    async def put(self, request):
        return text("put test passed")

    async def delete(self, request):
        return text("delete test passed")


def full_test(request):
    return json({"args": request.args,
                 "url": request.url,
                 "headers": request.headers,
                 "query_string": request.query_string})


async def tar_test(request):
    return asynctar.stream(response,
                           "/mnt/main/test_dicom_data",
                           'somefile.dat')

async def db_test(request):
    query = """select count(*) from file"""

    async with db.pool.acquire() as conn:
        records = await conn.fetch(query)
        return json(records)


blueprint.add_route(list_tests, '/')
blueprint.add_route(Test.as_view(), '/main')
blueprint.add_route(full_test, '/full')
blueprint.add_route(tar_test, '/tar')
blueprint.add_route(db_test, '/db')
