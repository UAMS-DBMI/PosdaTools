import os
from fastapi import FastAPI, APIRouter

from papi.util import db

from papi.routes import auth
from papi.routes import other
from papi.routes import collections
from papi.routes import studies
from papi.routes import series
from papi.routes import files
from papi.routes import iecs
from papi.routes import dump
from papi.routes import download
from papi.routes import vrstatus
from papi.routes import dashboard
from papi.routes import rois
from papi.routes import importer
from papi.routes import send_to_public_status

# configure importer
importer.FILE_STORAGE_PATH = os.environ.get(
    'FILE_STORAGE_PATH',
    "/home/posda/cache/created" 
)
importer.TEMP_STORAGE_PATH = os.environ.get(
    'TEMP_STORAGE_PATH',
    "/home/posda/cache/temp"
)
importer.FILE_STORAGE_ROOT = int(os.environ.get(
    'FILE_STORAGE_ROOT',
    3
))

if not os.path.exists(importer.TEMP_STORAGE_PATH):
    os.makedirs(importer.TEMP_STORAGE_PATH)


app = FastAPI()

@app.on_event("startup")
async def startup_event():
    print(20*"#", "database connecting")
    await db.setup(database='posda_files')
    print(20*"#", "database connected")

router_v1 = APIRouter()
router_v1.include_router(other.router, prefix="/other")
router_v1.include_router(collections.router, prefix="/collections")
router_v1.include_router(studies.router, prefix="/studies")
router_v1.include_router(series.router, prefix="/series")
router_v1.include_router(files.router, prefix="/files")
router_v1.include_router(iecs.router, prefix="/iecs")
router_v1.include_router(dump.router, prefix="/dump")
router_v1.include_router(download.router, prefix="/download")
router_v1.include_router(vrstatus.router, prefix="/vrstatus")
router_v1.include_router(dashboard.router, prefix="/dashboard")
router_v1.include_router(rois.router, prefix="/rois")
router_v1.include_router(importer.router, prefix="/import")
router_v1.include_router(send_to_public_status.router, prefix="/send_to_public_status")

app.include_router(auth.router)
app.include_router(router_v1, prefix="/v1")
# For backward compatiblity, also include the download router at the root
app.include_router(download.router)




