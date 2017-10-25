-- Name: VisibilityChangeEventsByCollectionForAllFiles
-- Schema: posda_files
-- Columns: ['collection', 'site', 'user_name', 'time', 'reason_for', 'count']
-- Args: ['collection']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files', 'show_hidden']
-- Description: Show Received before date by collection, site

select
  distinct project_name as collection, 
  site_name as site,
  user_name, 
  date_trunc('hour',time_of_change) as time, 
  reason_for, count(distinct file_id)
from
  file_visibility_change natural join
  ctp_file
where
  project_name = ?
group by collection, site, user_name, time, reason_for
order by time, collection, site