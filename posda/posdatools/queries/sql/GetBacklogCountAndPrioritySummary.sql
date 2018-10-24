-- Name: GetBacklogCountAndPrioritySummary
-- Schema: posda_backlog
-- Columns: ['collection', 'priority', 'num_requests']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'backlog_status']
-- Description: Get List of Collections with Backlog and Priority Counts

select
  distinct collection, file_count as priority, count(*) as num_requests
from
  submitter natural join request natural join collection_count_per_round
where
  not file_in_posda
group by collection, file_count
