-- Name: GetBackgroundReportFilename
-- Schema: posda_files
-- Columns: ['filename']
-- Args: ['file_id']
-- Tags: []
-- Description: Get the filename of a background report, by file_id

select root_path || '/' || rel_path as filename
from file
natural join file_location
natural join file_storage_root
where file_id = ?
