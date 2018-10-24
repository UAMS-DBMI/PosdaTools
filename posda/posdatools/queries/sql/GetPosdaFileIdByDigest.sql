-- Name: GetPosdaFileIdByDigest
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['digest']
-- Tags: ['NotInteractive', 'Backlog', 'used_in_file_import_into_posda']
-- Description: Get posda file id of file by file_digest

select
 file_id
from
  file
where
  digest = ?

