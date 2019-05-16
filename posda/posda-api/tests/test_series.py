import asynctest

from papi.resources import series
from papi.util import json_records

class TestIecs(asynctest.TestCase):
    async def test_get_single_series(self):
        with asynctest.patch("papi.util.db.fetch_one") as mock:
            mock.return_value = {
                'a': 1,
                'b': 2,
                'c': 'd'
            }
            result = await series.get_single_series(None, 1)
            self.assertEqual(result.body, json_records(mock.return_value).body)
