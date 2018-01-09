-- Name: GetFilesAndSopsBySeries
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'path']
-- Args: ['series_instance_uid']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets count of all files which are PET's which haven't been imported into file_pt_image yet.
-- 
-- 

select 
  distinct patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid,
  file_id, 
  root_path || '/' || rel_path as path
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  ctp_file natural join
  file_location natural join
  file_storage_root
where 
  series_instance_uid = ? and
  visibility is null