-- Name: public_copy_status
-- Schema: posda_files
-- Columns: ['success', 'num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['public_copy_status']
-- Description: Get public_copy_status by subprocess_invocation_id
--

select
  distinct success, count(*) as num_files
from public_copy_status
where subprocess_invocation_id = ?
group by success