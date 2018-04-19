from typing import NamedTuple


class Collection(NamedTuple):
    collection: str
    site: str

class CollectionDetail(NamedTuple):
    collection: str
    site: str
    count: int
