-- Name: RoundSummary2
-- Schema: posda_backlog
-- Columns: ['round_id', 'round_created', 'round_start', 'round_end', 'round_aborted', 'wait_count', 'process_count']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor']
-- Description: Summary of rounds

select
  round_id,
  round_created,
  round_start,  
  round_end,
  round_aborted,
  wait_count,
  process_count
from
  round
order by round_id