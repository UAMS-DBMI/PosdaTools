-- Name: GetPathsForActivityTP
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['activity_timepoint_id']
-- Tags: ['find_files']
-- Description: Get file ids and paths for files from posda database that are in the lastest timepoint
--

 SELECT
  distinct file_id, root_path || '/' || rel_path as path
from
  file_location natural join file_storage_root
  natural left join ctp_file
  natural join activity_timepoint_file
where
  activity_timepoint_id = ?
