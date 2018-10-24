-- Name: RoundCountsByCollection2Recent
-- Schema: posda_backlog
-- Columns: ['round_id', 'collection', 'round_created', 'q_time', 'duration', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority']
-- Args: ['collection']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Summary of rounds

select
  round_id, collection,
  round_created,
  round_start - round_created as q_time,  
  round_end - round_created as duration,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where collection = ? and (now() - round_end) < '1:00'
order by round_id, collection