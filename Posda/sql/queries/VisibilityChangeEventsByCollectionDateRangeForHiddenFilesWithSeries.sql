-- Name: VisibilityChangeEventsByCollectionDateRangeForHiddenFilesWithSeries
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'user_name', 'time', 'series_instance_uid', 'reason_for', 'count']
-- Args: ['collection', 'from', 'to']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files', 'show_hidden']
-- Description: Show Received before date by collection, site

select
  distinct project_name as collection, 
  site_name as site, patient_id,
  user_name, 
  date_trunc('hour',time_of_change) as time, 
  reason_for, series_instance_uid, count(*)
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and
  visibility is not null and
  time_of_change > ? and time_of_change < ?
group by 
  collection, site, patient_id, user_name, 
  time, reason_for, series_instance_uid
order by time, collection, site, patient_id, series_instance_uid