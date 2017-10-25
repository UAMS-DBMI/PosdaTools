-- Name: GetBacklogQueueSize
-- Schema: posda_backlog
-- Columns: ['num_files']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Get size of queue  in PosdaBacklog

select
 count(*) as num_files
from
  request
where
  file_in_posda is false 

