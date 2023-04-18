-- Name: FilesInSeriesForApplicationOfPrivateDisposition
-- Schema: posda_files
-- Columns: ['path', 'sop_instance_uid', 'modality']
-- Args: ['series_instance_uid']
-- Tags: ['find_files', 'ApplyDisposition']
-- Description: Get path, sop_instance_uid, and modality for all files in a series
-- 

select
  distinct root_path || '/' || rel_path as path, 
  sop_instance_uid, modality
from
  file_location natural join file_storage_root 
  natural join ctp_file natural join file_series
  natural join file_sop_common
where
  series_instance_uid = ?
