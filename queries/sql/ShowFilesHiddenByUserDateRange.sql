-- Name: ShowFilesHiddenByUserDateRange
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'reason', 'before', 'after', 'num_files', 'earliest', 'latest']
-- Args: ['user', 'from', 'to']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'old_hidden']
-- Description: Show Files Hidden By User Date Range

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  reason_for as reason,
  prior_visibility as before,
  new_visibility as after,
  min(time_of_change) as earliest,
  max(time_of_change) as latest,
  count(distinct file_id) as num_files
from 
  file_visibility_change natural join
  file_patient natural join
  file_study natural join
  file_series natural join 
  ctp_file
where
  user_name = ? and
  time_of_change > ? and time_of_change < ?
group by
   collection, site, 
   patient_id, study_instance_uid,
   series_instance_uid, reason, before, after
order by
  patient_id, study_instance_uid, series_instance_uid