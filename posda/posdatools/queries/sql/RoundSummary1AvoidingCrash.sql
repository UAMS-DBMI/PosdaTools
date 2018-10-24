-- Name: RoundSummary1AvoidingCrash
-- Schema: posda_backlog
-- Columns: ['round_id', 'round_start', 'duration', 'round_end', 'sum']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools']
-- Description: Summary of rounds

select
  distinct round_id,
  round_start, 
  round_end - round_start as duration, 
  round_end, 
  sum(num_entered + num_dups)
from
  round natural join round_collection
where
  round_end is not null 
group by 
  round_id, round_start, duration, round_end 
order by round_id