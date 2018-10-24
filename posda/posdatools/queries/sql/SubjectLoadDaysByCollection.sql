-- Name: SubjectLoadDaysByCollection
-- Schema: posda_backlog
-- Columns: ['collection', 'site', 'subj', 'time', 'number_of_files', 'max_delay', 'min_delay']
-- Args: ['interval_type', 'from', 'to', 'collection']
-- Tags: ['find_series', 'for_tracy', 'backlog_round_history']
-- Description: Get List of Series by Subject Name

select
  distinct collection, site, subj, date_trunc(?, time_received) as time,
  count(*) as number_of_files,
  max(time_entered - time_received) as max_delay,
  min(time_entered - time_received) as min_delay
from request natural join submitter
where time_received > ? and time_received < ?
  and collection = ?
group by collection, site, subj, time order by time desc, collection, site, subj