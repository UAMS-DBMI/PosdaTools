-- Name: FilesInSeriesWithVisibility
-- Schema: posda_files
-- Columns: ['file']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'find_files', 'used_in_simple_phi']
-- Description: Get files in a series from posda database
-- 

select
  distinct root_path || '/' || rel_path as file
from
  file_location natural join file_storage_root
  natural join ctp_file
  natural join file_series
where
  series_instance_uid = ?
