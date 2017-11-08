-- Name: ShowFilesHiddenByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'reason', 'before', 'after', 'user', 'num_files', 'earliest', 'latest']
-- Args: ['collection', 'site']
-- Tags: ['old_hidden']
-- Description: Show Files Hidden By User Date Range

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  reason_for as reason,
  prior_visibility as before,
  new_visibility as after,
  user_name as user,
  count(distinct file_id) as num_files,
  min(time_of_change) as earliest,
  max(time_of_change) as latest
from 
  file_visibility_change natural join
  file_patient natural join
  ctp_file
where
  project_name = ? and site_name = ?
group by
   collection, site, 
   patient_id,
   reason, before, after, user_name
order by
  earliest, patient_id