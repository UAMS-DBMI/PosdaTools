-- Name: InsertActivityTaskStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['activity_id', 'subprocess_invocation_id']
-- Tags: ['Insert', 'NotInteractive']
-- Description: Insert Initial Patient Status
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into activity_task_status(
  activity_id,
  subprocess_invocation_id,
  start_time,
  status_text,
  last_updated
) values (
  ?,
  ?,
  now(),
   'Initializing',
  now()
)