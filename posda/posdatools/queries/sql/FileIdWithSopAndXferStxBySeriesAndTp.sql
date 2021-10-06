-- Name: FileIdWithSopAndXferStxBySeriesAndTp
-- Schema: posda_files
-- Columns: ['file_id', 'series_instance_uid', 'sop_instance_uid', 'xfer_syntax', 'path']
-- Args: ['series_instance_uid', 'activity_timepoint_id']
-- Tags: ['activity_timepoint', 'decompression']
-- Description: Get file_id, sop, series, and xfer_syntax by series_instance_uid, and activity_timepoint_id
-- 

select
  file_id,  series_instance_uid, sop_instance_uid, xfer_syntax,
  root_path || '/' || rel_path as path
from
  file_series natural join file_sop_common 
  natural join activity_timepoint_file
  natural join file_meta
  natural join file_location
  natural join file_storage_root
where
  series_instance_uid = ?
  and activity_timepoint_id = ?