-- Name: VisibilityChangesBySeries
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'user_name', 'prior_visibility', 'new_visibility', 'time', 'reason_for', 'series_instance_uid', 'num_files']
-- Args: ['collection', 'site', 'series_instance_uid']
-- Tags: ['find_series', 'equivalence_classes', 'consistency', 'visual_review_results', 'hide_files']
-- Description: Get visual review status report by series for Collection, Site

select
  distinct project_name as collection, 
  site_name as site, patient_id,
  user_name, prior_visibility, new_visibility,
  date_trunc('hour',time_of_change) as time, 
  reason_for, series_instance_uid, count(*) as num_files
from
  file_visibility_change natural join
  ctp_file natural join 
  file_patient natural join 
  file_series
where
  project_name = ? and site_name = ? and
  series_instance_uid = ?
group by 
  collection, site, patient_id, user_name, prior_visibility, new_visibility,
  time, reason_for, series_instance_uid
order by time, collection, site, patient_id, series_instance_uid
