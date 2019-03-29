#!/usr/bin/env python
from papi.resources.importer import *
from unittest import mock
import asynctest
from sanic.exceptions import NotFound, InvalidUsage
import sanic.response

class ImportEventTest(asynctest.TestCase):
    def setUp(self):
        self.ie = ImportEvent()

    @asynctest.mock.patch('papi.resources.importer.json')
    @asynctest.mock.patch(
        "papi.resources.importer.create_import_event", return_value=99
    )
    async def test_import_event(self, create_import_event, json):
        request = mock.Mock()
        request.args = {"source": "testSource"}
        await self.ie.put(request)
        create_import_event.assert_called_once_with("testSource")
        json.assert_called()

    async def test_missing_event(self):
        request = mock.Mock()
        request.args = {}
        request.args["source"] = None
        with self.assertRaises(InvalidUsage):
            await self.ie.put(request)
