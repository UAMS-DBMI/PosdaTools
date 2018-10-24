-- Name: RoundSummaryWithCollectionDateRange
-- Schema: posda_backlog
-- Columns: ['round_id', 'collection', 'round_start', 'duration', 'round_end']
-- Args: ['from', 'to']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools']
-- Description: Summary of rounds

select
  distinct round_id, collection,
  round_start, 
  round_end - round_start as duration, 
  round_end
from
  round natural join round_collection
where
  round_end is not null and round_start > ? and round_end < ?
group by 
  round_id, collection, round_start, duration, round_end 
order by round_id