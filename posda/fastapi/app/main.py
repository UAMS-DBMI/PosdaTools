description = """
This is a complete listing of the Posda API.
This API is used internally by Posda and its various applications,
and can also be used by you.

## Test
this is just a *test*.

_this is some italics_

"""
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
from papi.routes import dicom_roots
from papi.routes import worker
from papi.routes import pathology
from papi.routes import work
from papi.routes import deface
from papi.routes import edits
from papi.routes import nifti
from papi.routes import sysstatus

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



# metadata for all tags that are used in routes
tags_metadata = [
    {
        "name": "Authentication",
        "description": "Operations related to authorization.",
    },
    {
        "name": "default",
        "description": "test",
    },
    {
        "name": "Other",
        "description": "Deprecated, testing, and other non-useful "
                       "operations. Do not use.",
    },
    {
        "name": "Collections",
        "description": "Retrieve collection info",
    },
]


app = FastAPI(
    title="PosdaAPI",
    description=description,
    version="0.1",
    root_path="/papi",
    openapi_tags=tags_metadata,
)

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
router_v1.include_router(dicom_roots.router, prefix="/dicom_roots")
router_v1.include_router(worker.router, prefix="/worker")
router_v1.include_router(pathology.router, prefix="/pathology")
router_v1.include_router(work.router, prefix="/work")
router_v1.include_router(deface.router, prefix="/deface")
router_v1.include_router(edits.router, prefix="/edits")
router_v1.include_router(nifti.router, prefix="/nifti")
router_v1.include_router(sysstatus.router, prefix="/sysstatus")

app.include_router(auth.router, prefix="/auth")
app.include_router(router_v1, prefix="/v1")
# For backward compatiblity, also include the download router at the root
app.include_router(download.router)
