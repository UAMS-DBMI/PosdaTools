-- Name: FilesByPatientForApplicationOfPrivateDisposition
-- Schema: posda_files
-- Columns: ['path', 'sop_instance_uid', 'modality']
-- Args: ['patient_id']
-- Tags: ['find_files', 'ApplyDisposition', 'edit_files']
-- Description: Get path, sop_instance_uid, and modality for all files in a series
-- 

select
  distinct root_path || '/' || rel_path as path, 
  sop_instance_uid, modality
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_patient
  natural join file_sop_common
where
 patient_id = ? and visibility is null
