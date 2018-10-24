-- Name: RoundWithIntervalOverlap
-- Schema: posda_backlog
-- Columns: ['round_id', 'collection', 'num_dups', 'round_created', 'round_start', 'duration', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority']
-- Args: ['collection', 'from', 'to']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools', 'backlog_round_history']
-- Description: Summary of rounds

select
  round_id, collection,
  round_created,
  round_start,  
  round_end - round_start as duration,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ? and 
  round_end > ? and round_start < ?
order by round_id, collection