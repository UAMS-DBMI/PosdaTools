-- Name: RoundStatsForDateRange
-- Schema: posda_backlog
-- Columns: ['time', 'number_of_files', 'max_delay', 'min_delay']
-- Args: ['interval', 'from', 'to']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'for_bill']
-- Description: Summary of rounds

select
  date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request
where time_received > ? and time_received < ?
group by time order by time desc