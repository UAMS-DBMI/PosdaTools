-- Name: FromDigestToDigestFromDicomEditCompare
-- Schema: posda_files
-- Columns: ['from_file_digest', 'to_file_digest']
-- Args: ['subprocess_invocation_id']
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events']
-- Description: Add a filter to a tab

select 
  from_file_digest, to_file_digest
from
  dicom_edit_compare
where
  subprocess_invocation_id = ?