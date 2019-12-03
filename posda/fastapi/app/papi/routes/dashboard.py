from fastapi import Depends, APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
import datetime
from starlette.responses import Response, FileResponse
from .auth import logged_in_user, User
from ..util import Database, asynctar

router = APIRouter()


@router.get("/")
async def test():
    raise HTTPException(detail="test error, not allowed", status_code=401)

@router.get("/slow_dbif_queries/{days}")
async def slow_dbif_queries(days: int, db: Database = Depends()):
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
    return await db.fetch(query, [days])


@router.get("/prbs")
async def PossiblyRunningBackgroundSubprocesses(db: Database = Depends()):
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
    return await db.fetch(query)

@router.get("/bsbu")
async def background_subprocess_stats_by_user_this_week(db: Database = Depends()):
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
    return await db.fetch(query)

@router.get("/fwt")
async def files_without_type(db: Database = Depends()):
    query = """\
        select * from files_without_type
        limit 20;
    """
    return await db.fetch(query)

@router.get("/fwl")
async def files_without_location(db: Database = Depends()):
    query = """\
        select * from files_without_location
        limit 20;
    """
    return await db.fetch(query)

@router.get("/ftc")
async def get_file_time_chart(db: Database = Depends()):
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
    return await db.fetch(query)

@router.get("/tla")
async def table_lock_alert(db: Database = Depends()):
    query = """\
    select pid,
      usename,
      pg_blocking_pids(pid) as blocked_by,
      query as blocked_query
    from pg_stat_activity
    where cardinality(pg_blocking_pids(pid)) > 0;
    """

    return await db.fetch(query)

@router.get("/qrvi")
async def get_query_runtime_versus_invocations(db: Database = Depends()):
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

    return await db.fetch(query)
