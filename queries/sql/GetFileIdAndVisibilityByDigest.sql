-- Name: GetFileIdAndVisibilityByDigest
-- Schema: posda_files
-- Columns: ['id', 'ctp_file_id', 'visibility']
-- Args: ['digest']
-- Tags: ['NotInteractive', 'used_in_import_edited_files']
-- Description: Get file_id, and current visibility by digest
-- For use in scripts
-- Not really intended for interactive use
-- 

select
  f.file_id as id,
  c.file_id as ctp_file_id,
  c.visibility as visibility
from
  file f left join ctp_file c
  using(file_id)
where
  f.file_id in (
  select file_id
  from
     file
  where
     digest = ?
)