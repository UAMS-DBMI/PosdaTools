from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse
from .auth import logged_in_user, User
from ..util import Database, asynctar

router = APIRouter(
    tags=["Visual Review Status"],
    dependencies=[logged_in_user]
)

@router.get("/")
async def test():
    raise HTTPException(detail="test error, not allowed", status_code=401)


@router.get("/find_vr_ready_to_begin_status_updates")
async def find_vr_ready_to_begin_status_updates(db: Database = Depends()):
    query = """\
        select
            b.visual_review_instance_id
        from
          activity_task_status a
          join visual_review_instance b
          	on b.subprocess_invocation_id = a.subprocess_invocation_id
        where
        	b.visual_review_reason = 'Activity Id: ' || a.activity_id
            and a.manual_update = true;
    """
    return await db.fetch(query)


@router.get("/get_reviewed_percentage_for_vr/{visual_review_instance_id}")
async def get_reviewed_percentage_for_vr(visual_review_instance_id: int, db: Database = Depends()):
    query = """\
        select
            ('' || processing_status::text || ' ' || ((count(*)/(select  sum(c) as t from (select count(*) as c from image_equivalence_class where visual_review_instance_id = $1 ) as sum_table)::float) * 100.0)::int || '%')::text as summary
        from
            image_equivalence_class
        where
            visual_review_instance_id = $1
        group by
            processing_status
    """
    return await db.fetch(query,[visual_review_instance_id])

@router.get("/update_activity_status/{visual_review_instance_id}/{new_status}")
async def update_activity_status(visual_review_instance_id: int, new_status: str, db: Database = Depends()):
    query = """\
        update
            activity_task_status
        set
            status_text = $2
        from
             visual_review_instance b
        where
            activity_task_status.manual_update = true
            and b.visual_review_instance_id = $1
            and b.visual_review_reason = 'Activity Id: ' || activity_task_status.activity_id
            and b.subprocess_invocation_id = activity_task_status.subprocess_invocation_id;
    """
    # TODO: This should not be returning this query, as it always returns []
    return await db.fetch(query, [visual_review_instance_id, new_status])

@router.get("/get_visible_bads_for_vr/{visual_review_instance_id}")
async def get_visible_bads_for_vr(visual_review_instance_id: int, db: Database = Depends()):
    query = """\
        select
            'Reviewed 100% , ' || count(file_id) || ' files need to be set to Bad and hidden to continue.' as summary
        from
            image_equivalence_class a
            natural join image_equivalence_class_input_image c
            natural join ctp_file d
        where
            visual_review_instance_id = $1
        	and a.review_status <> 'Good'
    	    and ( (a.review_status = 'Bad') or a.review_status = 'Blank' or a.review_status = 'Other' or a.review_status = 'Scout')
    """
    return await db.fetch(query, [visual_review_instance_id])

# TODO: This should not return [], and it probably should not be GET, but rather POST
@router.get("/finish_activity_status/{visual_review_instance_id}")
async def finish_activity_status(visual_review_instance_id: int, db: Database = Depends()):
    query = """\
        update
            activity_task_status
        set
            manual_update = false
        from
             visual_review_instance b
        where
            activity_task_status.manual_update = true
            and b.visual_review_instance_id = $1
            and b.visual_review_reason = 'Activity Id: ' || activity_task_status.activity_id
            and b.subprocess_invocation_id = activity_task_status.subprocess_invocation_id;
    """
    return await db.fetch(query, [visual_review_instance_id])
