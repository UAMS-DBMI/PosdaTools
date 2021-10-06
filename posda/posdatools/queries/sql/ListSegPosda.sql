-- Name: ListSegPosda
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'file_id', 'file_path']
-- Args: ['collection_like']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test', 'view_structured_reports']
-- Description: Add a filter to a tab
-- 

select 
  distinct project_name as collection, site_name as site,
  patient_id, study_instance_uid, series_instance_uid, modality
  file_id, root_path || '/' || rel_path as file_path
from
  dicom_file natural join file_patient natural join file_series
  natural join file_study natural join ctp_file
  join file_location using (file_id) natural join file_storage_root
where
  modality = 'SEG' and
  project_name like ?