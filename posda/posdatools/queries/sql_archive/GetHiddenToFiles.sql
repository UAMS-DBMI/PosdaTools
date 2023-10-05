-- Name: GetHiddenToFiles
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['Insert', 'NotInteractive', 'used_in_import_edited_files']
-- Description: Insert edit_event
-- For use in scripts
-- Not really intended for interactive use
-- 

select 
  f.file_id as file_id,
  c.visibility as visibility 
from
  dicom_edit_compare dec,
  file f,
  ctp_file c
where
  dec.to_file_digest = f.digest and
  f.file_id = c.file_id and 
  c.visibility is not null and
  dec.subprocess_invocation_id = ?