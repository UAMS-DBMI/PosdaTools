from sanic import response
from sanic.response import json, text, HTTPResponse
from sanic.views import HTTPMethodView

from ..util import db
from ..util import json_objects, json_records, json


async def test(request):
    return text("test error, not allowed", status=401)

async def slow_dbif_queries(request,days):
    query = """\
        select
        	*
        	,(query_end_time - query_start_time)::text  as query_time
        from
        	query_invoked_by_dbif
        where
        	query_end_time is not null
        	and (
        	( extract( day from(current_timestamp - query_end_time))::int < $1 )
        	or ( extract( day from(current_timestamp - query_start_time))::int < $1 )
        	)
        order by query_time desc
        limit 20;
    """
    return json_records(
        await db.fetch(query,[int(days)])
    )


async def PossiblyRunningBackgroundSubprocesses(request):
    query = """\
        select
          subprocess_invocation_id, background_subprocess_id,
          when_script_started, when_background_entered, command_line,
          (now()-when_background_entered)::text as time_in_background,
          background_pid
        from
          subprocess_invocation natural join background_subprocess
        where
          when_background_entered is not null and when_script_ended is null and
          subprocess_invocation_id != 0 and crash is null
        order by subprocess_invocation_id
        limit 20;
    """
    return json_records(
        await db.fetch(query)
    )

async def background_subprocess_stats_by_user_this_week(request):
    query = """\
        select
         invoking_user
         ,count(subprocess_invocation_id) as count_background
         ,avg(when_script_ended-when_background_entered)::text as avg_time_in_background
        from
          subprocess_invocation natural join background_subprocess
        where
          when_background_entered is not null
          and subprocess_invocation_id != 0
          and crash is null
          and extract(day from(now()- when_background_entered))::int < 7
        group by invoking_user;
    """
    return json_records(
        await db.fetch(query)
    )

async def files_without_type(request):
    query = """\
        select * from files_without_type
        limit 20;
    """
    return json_records(
        await db.fetch(query)
    )

async def get_file_time_chart(request):
    query = """\
    select
    	*
    from
    	file_imports_over_time
    where
    	importyear is not null
    order by
    	importyear
    	,importmonth;
    """
    return json_records(
        await db.fetch(query)
    )

async def table_lock_alert(request):
     query = """\
     select pid,
       usename,
       pg_blocking_pids(pid) as blocked_by,
       query as blocked_query
     from pg_stat_activity
     where cardinality(pg_blocking_pids(pid)) > 0;
     """
     return json_records(
         await db.fetch(query)
     )

async def get_query_runtime_versus_invocations(request):
     query = """\
     select
      query_name,
      max(query_start_time)::text  as last_invocation,
      count(query_invoked_by_dbif_id) as num_invocations,
      sum(query_end_time - query_start_time)::text  as total_query_time,
      extract(epoch from avg(query_end_time - query_start_time)) as avg_query_time
    from
      query_invoked_by_dbif
    where extract(day from query_start_time)::int < 31
    group by query_name
    order by avg_query_time  desc
    limit 120;
     """
     return json_records(
         await db.fetch(query)
     )
