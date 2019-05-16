import asynctest

from sanic.response import HTTPResponse
from papi.util import json_records
from papi.util import db


class TestDb(asynctest.TestCase):
    async def test_setup(self):
        # create_pool is not defined as async, so patch doesn't
        # detect it correctly. Need to force it to use CoroutineMock
        with asynctest.patch("asyncpg.create_pool", asynctest.CoroutineMock()) as mock:
            await db.setup()
            mock.assert_called_once_with()

            await db.setup(1, two=2)
            mock.assert_called_with(1, two=2)

    @asynctest.skip("can't mock async-with yet")
    async def test_fetch(self):
        m2 = asynctest.Mock()
        db.pool = asynctest.Mock()
        db.pool.acquire.return_value = m2
        await db.fetch('')


    @asynctest.skip("can't mock async-with yet")
    async def test_fetch_one(self):
        await db.fetch_one('')



class FakeRecord:
    """A fake 'record' object that behaves
    like asyncdb records; can be turned into a dict by calling dict()
    on it.
    """
    def __iter__(self):
        return iter([
            ['a', 1],
            ['b', 2],
        ])
    

class TestJsonRecords(asynctest.TestCase):
    def test_json_records_single(self):

        record = FakeRecord()

        
        result = json_records(record)

        self.assertIsInstance(result, HTTPResponse)
        self.assertEqual(result.status, 200)
        self.assertEqual(result.body, b'{"a":1,"b":2}')

    def test_json_records_iter(self):
        
        record = FakeRecord()
        result = json_records([
            record,
            record,
            record,
        ])

        self.assertIsInstance(result, HTTPResponse)
        self.assertEqual(result.status, 200)
        self.assertEqual(result.body, b'[{"a":1,"b":2},{"a":1,"b":2},{"a":1,"b":2}]')

    def test_json_records_failure(self):
        from sanic.exceptions import NotFound
        with self.assertRaises(NotFound):
            json_records(None)
