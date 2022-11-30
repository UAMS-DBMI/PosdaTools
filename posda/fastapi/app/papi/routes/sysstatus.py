from fastapi import Depends, APIRouter, HTTPException, Response
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse, HTMLResponse
from .auth import logged_in_user, User
from ..util import Database, asynctar

router = APIRouter()

@router.get("/")
async def test():
    raise HTTPException(detail="test error, not allowed", status_code=401)


@router.get("/system/{system_key}")
async def get_reviewed_percentage_for_vr(system_key: str, 
                                         db: Database = Depends()):
    # query = """\
    #     select
    #         ('' || processing_status::text || ' ' || ((count(*)/(select  sum(c) as t from (select count(*) as c from image_equivalence_class where visual_review_instance_id = $1 ) as sum_table)::float) * 100.0)::int || '%')::text as summary
    #     from
    #         image_equivalence_class
    #     where
    #         visual_review_instance_id = $1
    #     group by
    #         processing_status
    # """
    # return await db.fetch(query,[visual_review_instance_id])
    return HTMLResponse(f"<i>Test Message for {system_key}</i>",
                        headers={
                            "Access-Control-Allow-Origin": '*',
                        })
