-- Name: UploadCountsBetweenDatesByCollection
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'count']
-- Args: ['start_time', 'end_time', 'collection']
-- Tags: ['receive_reports']
-- Description: Counts of uploads received between dates for a collection
-- Organized by Subject, Study, Series, count of files_uploaded
-- 

select distinct 
  project_name, site_name, patient_id, 
  study_instance_uid, series_instance_uid,
  count(*)
from
  ctp_file natural join file_study
  natural join file_series
  natural join file_patient
where file_id in (
  select file_id
  from
    file_import natural join import_event
    natural join ctp_file
  where
    import_time > ? and import_time < ? 
    and project_name = ?
)
group by
  project_name, site_name, patient_id, 
  study_instance_uid, series_instance_uid
order by 
  project_name, site_name, patient_id, 
  study_instance_uid, series_instance_uid
 