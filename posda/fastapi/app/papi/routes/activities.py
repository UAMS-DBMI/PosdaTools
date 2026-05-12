from fastapi import Depends, APIRouter, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import List, Optional
from starlette.responses import FileResponse
import datetime
import os

from .files import get_data
from .auth import logged_in_user, User
from ..util import Database

API_URL = os.environ.get("POSDA_API_URL")
router = APIRouter(
    tags=["Activities"],
    dependencies=[logged_in_user],
    responses={
        401: {"description": "User is not logged in"},
    },
)


class ActivityListEntry(BaseModel):
    activity_id: int
    brief_description: str
    who_created: str
    when_created: datetime.datetime


@router.get("/")
async def get_all_activities(
    db: Database = Depends(), user: User = logged_in_user
) -> List[ActivityListEntry]:
    """
    Return a list of all active Activities in the system.
    """
    query = """
        select *
        from activity
        where when_closed is null
    """

    records = await db.fetch(query)

    return [ActivityListEntry(**dict(r)) for r in records]


class TimelineListEntry(BaseModel):
    timeline_id: int
    operation_name: str
    duration: datetime.timedelta
    activity_timepoint_id: Optional[int] = None
    file_count: Optional[int] = None
    user_name: str
    command_line: str
    when: datetime.datetime


@router.get("/{activity_id}")
async def get_activity(
    activity_id: int, db: Database = Depends(), user: User = logged_in_user
) -> List[TimelineListEntry]:
    """
    Return a list of Timeline Entries for the given activity.

    NOTE: timeline_id == subprocess_invocation_id
    """
    query = """

        with timepoints as (
            select 
                activity_id,
                a.when_created as activity_created,
                brief_description as activity_description,
                activity_timepoint_id,
                t.when_created as timepoint_created,
                comment,
                creating_user,
                (
                    select count(file_id)
                    from activity_timepoint_file atf
                    where atf.activity_timepoint_id = t.activity_timepoint_id
                ) as file_count
            from
                activity a
                join activity_timepoint t using (activity_id)
            where
                activity_id = $1
            order by
                t.when_created desc

        ), inbox_content as (
        select
            user_name,
            user_inbox_content_id as timeline_id,
            operation_name,
            when_script_started as when, 
            when_script_ended as ended,
            when_script_ended - when_script_started as duration,
            file_id,
            subprocess_invocation_id as sub_id,
            command_line,
            file_id_in_posda as spreadsheet_file_id

            from activity_inbox_content
            natural join user_inbox
            natural join user_inbox_content
            natural join background_subprocess_report
            natural join background_subprocess
            natural join subprocess_invocation
            natural left join spreadsheet_uploaded
        where
            activity_id = $1
        order by
            when_script_started desc
        )

        select *
        from inbox_content
        left join timepoints 
            on timepoints.timepoint_created 
                between inbox_content.when and inbox_content.ended
    """

    records = await db.fetch(query, [activity_id])

    return [TimelineListEntry(**dict(r)) for r in records]


class ReportEntry(BaseModel):
    file_id: int
    name: str


class TimelineEntry(BaseModel):
    command_line: str
    start_time: datetime.datetime
    end_time: Optional[datetime.datetime] = None
    operation_name: str
    invoking_user: str
    activity_timepoint_id: Optional[int] = None
    reports: List[ReportEntry]


class TimepointListEntry(BaseModel):
    activity_timepoint_id: int
    when_created: datetime.datetime
    comment: Optional[str] = None
    creating_user: Optional[str] = None
    file_count: int


class TimepointFilesResponse(BaseModel):
    activity_id: int
    activity_timepoint_id: int
    file_ids: List[int]
    count: int


async def _resolve_timepoint(
    db: Database,
    activity_id: Optional[int],
    timepoint_id: Optional[int],
) -> tuple[int, int]:
    """Returns (activity_id, timepoint_id), resolving from the other if one is missing."""
    if activity_id is not None and timepoint_id is not None:
        tp = await db.fetch_one(
            """
            select activity_timepoint_id, activity_id
            from activity_timepoint
            where activity_timepoint_id = $1 and activity_id = $2
            """,
            [timepoint_id, activity_id],
        )
        if tp is None:
            raise HTTPException(
                status_code=404,
                detail=f"Timepoint {timepoint_id} not found for activity {activity_id}",
            )
        return activity_id, timepoint_id

    elif activity_id is not None:
        tp = await db.fetch_one(
            """
            select activity_timepoint_id
            from activity_timepoint
            where activity_id = $1
            order by when_created desc
            limit 1
            """,
            [activity_id],
        )
        if tp is None:
            raise HTTPException(
                status_code=404,
                detail=f"No timepoints found for activity {activity_id}",
            )
        return activity_id, tp["activity_timepoint_id"]

    else:
        tp = await db.fetch_one(
            """
            select activity_timepoint_id, activity_id
            from activity_timepoint
            where activity_timepoint_id = $1
            """,
            [timepoint_id],
        )
        if tp is None:
            raise HTTPException(status_code=404, detail=f"Timepoint {timepoint_id} not found")
        return tp["activity_id"], timepoint_id


async def _fetch_timepoint_files(
    db: Database,
    activity_id: int,
    timepoint_id: int,
) -> TimepointFilesResponse:
    records = await db.fetch(
        """
        select file_id
        from activity_timepoint_file
        where activity_timepoint_id = $1
        order by file_id
        """,
        [timepoint_id],
    )
    file_ids = [r["file_id"] for r in records]
    return TimepointFilesResponse(
        activity_id=activity_id,
        activity_timepoint_id=timepoint_id,
        file_ids=file_ids,
        count=len(file_ids),
    )


@router.get("/timepoints/{timepoint_id}/files")
async def get_timepoint_files(
    timepoint_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> TimepointFilesResponse:
    """Return files for a timepoint; looks up the activity automatically."""
    act_id, tp_id = await _resolve_timepoint(db, None, timepoint_id)
    return await _fetch_timepoint_files(db, act_id, tp_id)


@router.get("/{activity_id}/timepoints")
async def get_activity_timepoints(
    activity_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> List[TimepointListEntry]:
    """Return all timepoints for an activity, newest first."""
    records = await db.fetch(
        """
        select
            at.activity_timepoint_id,
            at.when_created,
            at.comment,
            at.creating_user,
            count(atf.file_id)::int as file_count
        from activity_timepoint at
        left join activity_timepoint_file atf using (activity_timepoint_id)
        where at.activity_id = $1
        group by
            at.activity_timepoint_id,
            at.when_created,
            at.comment,
            at.creating_user
        order by at.when_created desc
        """,
        [activity_id],
    )
    return [TimepointListEntry(**dict(r)) for r in records]


@router.get("/{activity_id}/timepoints/files")
async def get_activity_latest_timepoint_files(
    activity_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> TimepointFilesResponse:
    """Return files for the latest timepoint of an activity."""
    act_id, tp_id = await _resolve_timepoint(db, activity_id, None)
    return await _fetch_timepoint_files(db, act_id, tp_id)


@router.get("/{activity_id}/timepoints/{timepoint_id}/files")
async def get_activity_timepoint_files(
    activity_id: int,
    timepoint_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> TimepointFilesResponse:
    """Return files for a specific timepoint of an activity."""
    act_id, tp_id = await _resolve_timepoint(db, activity_id, timepoint_id)
    return await _fetch_timepoint_files(db, act_id, tp_id)


@router.get("/{activity_id}/{timeline_id}")
async def get_timeline_entry(
    activity_id: int,
    timeline_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> TimelineEntry:
    """
    Return details about a single Timeline Entry.
    """

    reports = await db.fetch(
        """
        select
            file_id, name
        from
                background_subprocess_report
        where background_subprocess_id = (
                select background_subprocess_id
                from background_subprocess
                where subprocess_invocation_id = $1
        )
    """,
        [timeline_id],
    )

    reports = [ReportEntry(**dict(r)) for r in reports]

    query = """
        select
            *
        from
            subprocess_invocation
            natural join background_subprocess
            join activity_task_status using (subprocess_invocation_id)
            left join activity_timepoint
                on activity_timepoint.activity_id = activity_task_status.activity_id
                and activity_timepoint.when_created 
                    between background_subprocess.when_script_started 
                    and background_subprocess.when_script_ended
        where
            background_subprocess.subprocess_invocation_id = $1
    """

    details = await db.fetch_one(query, [timeline_id])

    details = dict(details)
    details["reports"] = reports

    return TimelineEntry(**details)


@router.get("/{activity_id}/{timeline_id}/input")
async def get_timeline_entry_input(
    activity_id: int,
    timeline_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> FileResponse:
    """
    Return the raw input that was given to this subprocess. Usually this
    is a spreadsheet, or at least looks like one.
    """

    query = """\
        select input_file_id
        from work
        where subprocess_invocation_id = $1
    """

    record = await db.fetch_one(query, [timeline_id])

    response = await get_data(record["input_file_id"], db)
    response.headers["P-file_id"] = str(record["input_file_id"])

    return response


@router.get("/{activity_id}/{timeline_id}/output")
async def get_timeline_entry_output(
    activity_id: int,
    timeline_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
) -> FileResponse:
    """
    Return the raw output (stdout) that this subprocess produced.
    """

    query = """\
        select stdout_file_id
        from work
        where subprocess_invocation_id = $1
    """

    record = await db.fetch_one(query, [timeline_id])

    response = await get_data(record["stdout_file_id"], db)
    response.headers["P-file_id"] = str(record["stdout_file_id"])

    return response


@router.get("/{activity_id}/{timeline_id}/errors")
async def get_timeline_entry_errors(
    activity_id: int,
    timeline_id: int,
    db: Database = Depends(),
    user: User = logged_in_user,
):
    """
    Return the raw errors (stderr) that this subprocess produced.
    """

    query = """\
        select stderr_file_id
        from work
        where subprocess_invocation_id = $1
    """

    record = await db.fetch_one(query, [timeline_id])

    response = await get_data(record["stderr_file_id"], db)
    response.headers["P-file_id"] = str(record["stderr_file_id"])

    return response


