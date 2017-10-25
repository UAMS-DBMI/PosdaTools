-- Name: WhatHasComeInRecently
-- Schema: posda_backlog
-- Columns: ['collection', 'site', 'time', 'number_of_files', 'max_delay', 'min_delay']
-- Args: ['interval', 'from', 'to']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history', 'for_bill_counts']
-- Description: A query to tell you what has been recently received:<ul>
--   <li>interval = 'year' | 'month' | 'week' | 'day' | 'hour' | 'minute' | 'sec'</li>
--   <li>from = start date/time (midnight if time not included)</li>
--   <li>to = end date/time (midnight if time not included)</li>
-- </ul>

select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
group by collection, site, time order by time desc, collection, site