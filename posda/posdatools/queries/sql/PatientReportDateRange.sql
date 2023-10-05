-- Name: PatientReportDateRange
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'study_description', 'series_instance_uid', 'series_description', 'num_files', 'earliest_upload', 'latest_upload', 'num_uploads']
-- Args: ['collection', 'site', 'patient_id', 'start_time', 'end_time']
-- Tags: ['meta', 'test', 'hello', 'bills_test']
-- Description: Add a filter to a tab

select
  distinct project_name as collection,
  site_name as site,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description,
  count(distinct file_id) as num_files,
  min(import_time) as earliest_upload,
  max(import_time) as latest_upload,
  count(distinct import_event_id) as num_uploads
from
  file_patient natural join file_study natural join
  file_series natural join ctp_file natural join
  file_import natural join import_event
where
  project_name = ? and
  site_name = ? and
  patient_id = ? and
  import_time > ? and
  import_time < ?
group by 
  collection, site,
  patient_id, study_instance_uid, study_description,
  series_instance_uid, series_description
order by
  study_instance_uid, series_instance_uid, num_files