-- Name: FilesInSeriesForApplyingPrivateDisposition
-- Schema: posda_files
-- Columns: ['path', 'sop_instance_uid', 'modality']
-- Args: ['series_instance_uid']
-- Tags: ['SeriesSendEvent', 'by_series', 'find_files', 'ApplyDisposition']
-- Description: Get Sop Instance UID, file_path, modality for all files in a series

select
  distinct file_id, root_path || '/' || rel_path as path, sop_instance_uid, 
  modality
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_sop_common natural join file_series
where
  series_instance_uid = ? and visibility is null
