-- Name: ListOfToFilePathsByEditId
-- Schema: posda_files
-- Columns: ['digest', 'path']
-- Args: ['subprocess_invocation_id']
-- Tags: ['find_series', 'dicom_file_type']
-- Description: List of Resulting Edit Files (with Digest) By Edit Event
-- 

select 
  distinct to_file_digest as digest, to_file_path as path
from
  dicom_edit_compare
where
  subprocess_invocation_id = ?