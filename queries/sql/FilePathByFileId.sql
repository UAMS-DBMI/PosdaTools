-- Name: FilePathByFileId
-- Schema: posda_files
-- Columns: ['path']
-- Args: ['file_id']
-- Tags: ['SeriesSendEvent', 'by_series', 'find_files', 'for_send', 'for_comparing_dups', 'used_in_file_import_into_posda']
-- Description: Get file path from id

select
  root_path || '/' || rel_path as path
from
  file_location natural join file_storage_root
where
  file_id = ?