-- Name: FilesInSeriesForApplicationOfPrivateDisposition2
-- Schema: posda_files
-- Columns: ['path', 'sop_instance_uid', 'modality', 'file_id']
-- Args: ['series_instance_uid']
-- Tags: ['find_files', 'ApplyDisposition']
-- Description: Get path, sop_instance_uid, and modality and file_id for all files in a series
-- 

select
  distinct root_path || '/' || rel_path as path, 
  sop_instance_uid, modality, file_id
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_sop_common
where
  series_instance_uid = ? and visibility is null
