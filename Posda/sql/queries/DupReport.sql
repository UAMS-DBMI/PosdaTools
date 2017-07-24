-- Name: DupReport
-- Schema: posda_backlog
-- Columns: ['collection', 'num_files', 'num_dups', 'percent_dups']
-- Args: []
-- Tags: ['Backlog', 'Backlog Monitor', 'backlog_analysis_reporting_tools']
-- Description: Report on Percentage of duplicates by collection

select
  distinct collection,
  sum(num_entered) num_files,
  sum(num_dups) num_dups,
  (cast(sum(num_dups) as float)/cast((sum(num_entered) + sum(num_dups)) as float))*100.0 as
   percent_dups
from
  round_collection
group by collection
order by percent_dups desc