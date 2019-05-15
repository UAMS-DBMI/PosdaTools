import asynctest

from papi.resources import iecs
from papi.util import json_records

class TestIecs(asynctest.TestCase):
    async def test_iec_details(self):
        with asynctest.patch("papi.util.db.fetch") as mock:
            mock.return_value = {
                'a': 1,
                'b': 2,
                'c': 'd'
            }
            result = await iecs.get_iec_details(None, 1)
            self.assertEqual(result.body, json_records(mock.return_value).body)

    async def test_iec_files(self):
        with asynctest.patch("papi.util.db.fetch") as mock:
            mock.return_value = [
                [1],
                [2],
            ]
            result = await iecs.get_iec_files(None, 1)
            self.assertEqual(result.body, b'{"file_ids":[1,2]}')

