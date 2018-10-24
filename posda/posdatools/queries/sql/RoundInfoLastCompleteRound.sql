-- Name: RoundInfoLastCompleteRound
-- Schema: posda_backlog
-- Columns: ['round_id', 'collection', 'round_created', 'round_start', 'round_end', 'round_aborted', 'wait_count', 'process_count', 'num_entered', 'num_failed', 'num_dups', 'num_requests', 'priority']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Summary of round by id

select
  round_id, collection,
  round_created,
  round_start,  
  round_end,
  round_aborted,
  wait_count,
  process_count,
  num_entered,
  num_failed,
  num_dups,
  num_requests,
  priority
from
  round natural join round_counts natural join round_collection
where round_id in (
  select max(round_id) as round_id from round where round_end is not null
)
order by round_id, collection