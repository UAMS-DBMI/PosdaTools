-- Name: CopyToPublicStatus
-- Schema: posda_queries
-- Columns: ['success', 'count']
-- Args: ['subprocess_invocation_id']
-- Tags: ['NotInteractive']
-- Description:  View a simple report on the status of a Copy to Public operation.

select success, count(file_id) 
from public_copy_status 
where subprocess_invocation_id = ?
group by success