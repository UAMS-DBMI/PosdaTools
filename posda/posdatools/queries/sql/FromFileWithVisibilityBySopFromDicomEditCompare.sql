-- Name: FromFileWithVisibilityBySopFromDicomEditCompare
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'from_file_id', 'from_file_visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events']
-- Description: Add a filter to a tab

select 
  sop_instance_uid,
  file_id as from_file_id,
  visibility as from_file_visibility
from
  ctp_file natural join file natural join file_sop_common,
  dicom_edit_compare
where
  from_file_digest = file.digest and
  subprocess_invocation_id = ?
order by sop_instance_uid