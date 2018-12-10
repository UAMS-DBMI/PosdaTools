-- Name: PatientStudySeriesForFile
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'path']
-- Args: ['file_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  patient_id, study_instance_uid, series_instance_uid, root_path || '/' || rel_path as path
from
  file_patient natural join file_series natural join
  file_study natural join file_location natural join file_storage_root
where file_id = ?