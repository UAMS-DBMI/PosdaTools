-- Name: GetFilesAndSopsByStudy
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'path']
-- Args: ['study_instance_uid']
-- Tags: ['ImageEdit', 'edit_files']
-- Description: Get File id and visibility for all files in a series

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
  file_location natural join
  file_storage_root natural left join
  ctp_file
where 
  study_instance_uid = ? and
  visibility is null