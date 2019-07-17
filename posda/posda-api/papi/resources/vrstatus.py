from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import db
from ..util import json_objects, json_records, json


async def test(request):
    return text("test error, not allowed", status=401)

async def find_vr_ready_to_begin_status_updates(request):
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
    return json_records(
        await db.fetch(query)
    )


async def get_reviewed_percentage_for_vr(request, visual_review_instance_id):
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
    return json_records(
        await db.fetch(query,[int(visual_review_instance_id)])
    )

async def update_activity_status(request, visual_review_instance_id,new_status):
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
    return json_records(
        await db.fetch(query,[int(visual_review_instance_id),new_status])
    )

async def get_visible_bads_for_vr(request, visual_review_instance_id):
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
    	    and ( (a.review_status = 'Bad' and d.visibility is null) or a.review_status = 'Blank' or a.review_status = 'Other' or a.review_status = 'Scout')
    """
    return json_records(
        await db.fetch(query,[int(visual_review_instance_id)])
    )

async def finish_activity_status(request, visual_review_instance_id):
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
    return json_records(
        await db.fetch(query,[int(visual_review_instance_id)])
    )
