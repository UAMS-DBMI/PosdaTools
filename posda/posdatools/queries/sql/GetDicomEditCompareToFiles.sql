-- Name: GetDicomEditCompareToFiles
-- Schema: posda_files
-- Columns: ['path', 'file_id', 'project_name', 'visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility
-- 
-- NB: Normally there should be no file_id (i.e. file has not been imported)

select 
  path,
  file_id,
  project_name,
  visibility
from 
  (
    select to_file_path as path, to_file_digest as digest
    from dicom_edit_compare
    where subprocess_invocation_id = ?
  ) as foo natural left join
  file natural left join ctp_file