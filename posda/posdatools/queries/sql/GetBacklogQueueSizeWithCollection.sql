-- Name: GetBacklogQueueSizeWithCollection
-- Schema: posda_backlog
-- Columns: ['collection', 'num_files']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Get size of queue  in PosdaBacklog

select
 distinct collection, count(*) as num_files
from
  request natural join submitter
where
  file_in_posda is false
group by collection

