-- Name: GetCountOfEditsBySubprocessInvocationId
-- Schema: posda_files
-- Columns: ['num_edits']
-- Args: ['subprocess_invocation_id']
-- Tags: ['meta', 'test', 'hello', 'import_files_tp']
-- Description: Get count of files edited by an edit process
-- 

select 
  count(*) as num_edits
from
  dicom_edit_compare
where
  subprocess_invocation_id = ?