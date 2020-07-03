-- Name: public_copy_status_all
-- Schema: posda_files
-- Columns: ['activity_id', 'subprocess_invocation_id', 'success', 'num_files']
-- Args: []
-- Tags: ['public_copy_status']
-- Description: Get public_copy_status by subprocess_invocation_id
--

select
  activity_id, subprocess_invocation_id, success, count(file_id) as num_files
from public_copy_status join activity_task_status using (subprocess_invocation_id)
group by activity_id, subprocess_invocation_id, success
