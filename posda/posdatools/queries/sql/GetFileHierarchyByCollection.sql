-- Name: GetFileHierarchyByCollection
-- Schema: posda_files
-- Columns: ['path', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'file_id']
-- Args: ['collection']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get root_path for a file_storage_root
-- 

select 
  distinct root_path || '/' || rel_path as path,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  file_id 
from 
  ctp_file natural join
  file_patient natural join
  file_study natural join
  file_series natural join
  file_location natural join
  file_storage_root
where
  project_name = ?