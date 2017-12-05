-- Name: VisibilityChangeEventsByCollectionForHiddenFiles
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'user_name', 'time', 'reason_for', 'count']
-- Args: ['collection']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files', 'old_hidden']
-- Description: Show Received before date by collection, site

select
  distinct project_name as collection, 
  site_name as site, patient_id,
  user_name, 
  date_trunc('hour',time_of_change) as time, 
  reason_for, count(*)
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and
  visibility is not null
group by collection, site, patient_id, user_name, time, reason_for
order by time, collection, site, patient_id