-- Name: GetDicomEditCompareDigestsAndToPath
-- Schema: posda_files
-- Columns: ['from_file_digest', 'to_file_digest', 'to_file_path']
-- Args: ['subprocess_invocation_id']
-- Tags: ['meta', 'test', 'hello', 'import_files_tp']
-- Description: Get file digests and to_file_path from dicom_edit_compare by edit_id
-- 

select 
  from_file_digest, to_file_digest, to_file_path
from
  dicom_edit_compare
where
  subprocess_invocation_id = ?