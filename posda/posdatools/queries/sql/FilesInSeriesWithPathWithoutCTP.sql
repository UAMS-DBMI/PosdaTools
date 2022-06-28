-- Name: FilesInSeriesWithPathWithoutCTP
-- Schema: posda_files
-- Columns: ['file']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'find_files', 'Structured Report']
-- Description: Get files in a series from posda database without ctp tags(visibility)
--

select
  distinct root_path || ''/'' || rel_path as file
from
  file_location natural join file_storage_root
  natural join file_series
where
  series_instance_uid = ?;
