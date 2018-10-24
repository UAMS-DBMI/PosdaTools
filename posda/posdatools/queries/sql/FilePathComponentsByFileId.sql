-- Name: FilePathComponentsByFileId
-- Schema: posda_files
-- Columns: ['root_path', 'rel_path']
-- Args: ['file_id']
-- Tags: ['SeriesSendEvent', 'by_series', 'find_files', 'for_send', 'for_comparing_dups', 'used_in_file_import_into_posda']
-- Description: Get file path from id

select
  root_path, rel_path
from
  file_location natural join file_storage_root
where
  file_id = ?