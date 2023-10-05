-- Name: TestThisOne
-- Schema: posda_files
-- Columns: ['patient_id', 'patient_import_status', 'total_files', 'min_time', 'max_time', 'num_studies', 'num_series']
-- Args: ['project_name', 'site_name', 'PatientStatus']
-- Tags: []
-- Description: 

select
  patient_id, patient_import_status,
  count(distinct file_id) as total_files,
  min(import_time) min_time, max(import_time) as max_time,
  count(distinct study_instance_uid) as num_studies,
  count(distinct series_instance_uid) as num_series
from
  ctp_file natural join file natural join
  file_import natural join import_event natural join
  file_study natural join file_series natural join file_patient
  natural join patient_import_status
where
  project_name = ? and site_name = ?
group by patient_id, patient_import_status
