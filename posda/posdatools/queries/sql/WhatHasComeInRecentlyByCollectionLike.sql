-- Name: WhatHasComeInRecentlyByCollectionLike
-- Schema: posda_backlog
-- Columns: ['collection', 'site', 'time', 'number_of_files', 'max_delay', 'min_delay']
-- Args: ['interval', 'from', 'to', 'collection_like']
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_round_history']
-- Description: Summary of rounds
-- 

select
  distinct collection, site, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
and collection like ?
group by collection, site, time order by time desc, collection, site