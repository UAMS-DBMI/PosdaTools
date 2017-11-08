-- Name: ToFileWithVisibilityBySopFromDicomEditCompare
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'to_file_id', 'to_file_visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events']
-- Description: Add a filter to a tab

select 
  sop_instance_uid,
  file_id as to_file_id,
  visibility as to_file_visibility
from
  ctp_file natural join file natural join file_sop_common,
  dicom_edit_compare
where
  to_file_digest = file.digest and
  subprocess_invocation_id = ?
order by sop_instance_uid