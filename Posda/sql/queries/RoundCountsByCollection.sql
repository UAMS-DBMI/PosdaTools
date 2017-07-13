-- Name: RoundCountsByCollection
-- Schema: posda_backlog
-- Columns: ['round_id', 'num_requests']
-- Args: ['collection']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor']
-- Description: Summary of rounds

select 
  round_id, num_requests
from round natural join round_counts
where collection = ?