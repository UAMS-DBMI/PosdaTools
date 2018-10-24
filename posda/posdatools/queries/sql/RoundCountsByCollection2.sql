-- Name: RoundCountsByCollection2
-- Schema: posda_backlog
-- Columns: ['round_id', 'collection', 'num_dups', 'round_created', 'round_start', 'round_end', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority']
-- Args: ['collection']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools']
-- Description: Summary of rounds

select
  round_id, collection,
  round_created,
  round_start,  
  round_end,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ?
order by round_id, collection