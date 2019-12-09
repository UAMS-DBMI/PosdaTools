-- Name: GetActivityTaskStatusAll
-- Schema: posda_files
-- Columns: ['subprocess_invocation_id', 'operation_name', 'start_time', 'last_updated', 'status_text']
-- Args: ['activity_id']
-- Tags: ['Insert', 'NotInteractive']
-- Description: Insert Initial Patient Status
-- For use in scripts
-- Not really intended for interactive use


select
  subprocess_invocation_id,
  operation_name,
  start_time,
  last_updated,
  status_text
from
  activity_task_status natural join subprocess_invocation
where
  activity_id = ?
order by subprocess_invocation_id