from starlette.testclient import TestClient

from main import app
from papi.util import Database


client = TestClient(app)


class FakeDatabase:
    async def fetch_one(self, *args, **kwargs):
        return FakeDatabase.one_return

    async def fetch(self, *args, **kwargs):
        return FakeDatabase.many_return

app.dependency_overrides[Database] = FakeDatabase



# def test_studies():
#     FakeDatabase.one_return = {
#         'study_date': '2019-01-01',
#         'study_time': 'lbarg',
#         'series_count': 4

#     }

#     response = client.get("/studies/invalid_uid")
#     assert response.status_code == 200
#     assert response.json() == {'series_count': 4, 'study_date': '2019-01-01', 'study_time': 'lbarg'}

def test_collections():
    FakeDatabase.many_return = [{
        'collection': 'FakeCollectionName',
        'site': 'FakeSiteName',
        'file_count': 0,
    }]

    response = client.get("/v1/collections/")
    assert response.status_code == 200
