from typing import List
from .queries import Query

class Activity:
    activity_id: int

    def __init__(self, activity_id) -> None:
        self.activity_id = activity_id
        self.collection_name = None
        self.site_name = None

        for row in Query('GetActivityInfo').run(activity_id=activity_id):
            self.desc = row.brief_description
            self.when_created = row.when_created
            self.who_created = row.who_created
            self.when_closed = row.when_closed


    def _get_collection_and_site(self) -> None:
        if self.collection_name is None:
            for row in Query('CollectionSiteFromTp').run(
                self.latest_timepoint()
            ):
                self.collection_name = row.collection_name
                self.site_name = row.site_name
    
    def collection(self) -> str:
        self._get_collection_and_site()
        return self.collection_name

    def site(self) -> str:
        self._get_collection_and_site()
        return self.site_name

    def site_code(self) -> int:
        for row in Query('GetSiteCodeBySite').run(self.site_name):
            return row.site_code

    def latest_timepoint(self) -> int:
        for row in Query('LatestActivityTimepointsForActivity').run(
            self.activity_id
        ):
            return row.activity_timepoint_id

    def all_timepoints(self) -> List[int]:
        pass

    def all_file_ids(self) -> List[int]:
        pass


