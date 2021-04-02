from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter()

from .auth import logged_in_user, User

from ..util import Database


class CollectionInfo(BaseModel):
    collection: str
    site: str
    file_count: int

@router.get("/start/{activity_timepoint_id}")
async def get_files_from_activity(activity_timepoint_id: int, db: Database = Depends()):
    query = """\
        select
          root_path + rel_path as filepath
        from
          activity_timepoint_file
          natural join from file
          natural join file_location
          natural join file_storage_root
        where
          activity_timepoint_id = $1
    """
    results = await db.fetch(query, [activity_id])
    IMAGES = []
    PREFIX = result['root_path'] + '/'
    for result in results:
        IMAGES.append(result['rel_path'])
    return IMAGES


@router.get("/{svsid}")
async def create_preview_from_SVS(svsid: int):
    ret = []
    mytif = get_SVS(svsid)
    for i, page in enumerate(mytif.pages):
        if (i == 1 or page.tags['NewSubfileType'] != 0 ) and (page.size < 5000000):
            data = page.asarray()
            str = "{}_page{}.jpg".format(svsid,i)
            im = Image.fromarray(data)
            im.save(str)
            ret.append(str)
    return ret

def get_SVS(svsid: int):
    mypath = PREFIX + IMAGES[svsid]
    return TiffFile(mypath)

@router.get("/getcount")
def get_current_count():
    return len(IMAGES)
