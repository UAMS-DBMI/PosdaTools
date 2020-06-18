-- Name: CopyToPublicStatusAll
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'success', 'count']
-- Args: []
-- Tags: ['NotInteractive']
-- Description:  View a simple report on the status of a Copy to Public operation.
--

select subprocess_invocation_id, success, count(file_id) 
from public_copy_status 
group by subprocess_invocation_id, success