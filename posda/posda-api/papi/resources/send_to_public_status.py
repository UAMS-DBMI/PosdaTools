from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import db
from ..util import json_objects, json_records, json


async def test(request):
    return text("test error, not allowed", status=401)

async def find_send_ready_to_begin_status_updates(request):
    query = """\
        select distinct
                subprocess_invocation_id
        from
                activity_task_status
                natural join public_copy_status
        where
                manual_update = true
    """
    return json_records(
        await db.fetch(query)
    )




async def get_success_percentage_for_send(request, subprocess_invocation_id):
    query = """\
        select
            ('' || success::text || ' ' || ((count(*)/(select  sum(c) as t from
            ( select
                count(file_id) as c
                from
                    activity_timepoint_file
                where
                    activity_timepoint_id = (
                	select max(activity_timepoint_id)
                	from activity_timepoint
                	where activity_id = (
                		select activity_id
                		from activity_task_status
                		where subprocess_invocation_id = $1 )))
                		as sum_table)::float) * 100.0)::int || '%')::text as summary
        from
            public_copy_status
        where
            subprocess_invocation_id = $1
        group by
            success
            """
    return json_records(
        await db.fetch(query,[int(subprocess_invocation_id)])
    )

async def update_activity_status(request, subprocess_invocation_id,new_status):
    query = """\
        update
            activity_task_status
        set
            status_text = $2
        where
            activity_task_status.manual_update = true
            and subprocess_invocation_id = $1
    """
    return json_records(
        await db.fetch(query,[int(subprocess_invocation_id),new_status])
    )

async def finish_activity_status(request, subprocess_invocation_id):
    query = """\
        update
            activity_task_status
        set
            manual_update = false
        where
            activity_task_status.manual_update = true
            and subprocess_invocation_id = $1
    """
    return json_records(
        await db.fetch(query,[int(subprocess_invocation_id)])
    )
