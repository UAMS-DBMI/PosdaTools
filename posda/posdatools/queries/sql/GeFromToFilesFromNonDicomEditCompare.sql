-- Name: GeFromToFilesFromNonDicomEditCompare
-- Schema: posda_files
-- Columns: ['from_file_id', 'to_file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Retrieve entries from patient_mapping table

select 
  file_id as from_file_id, 
  foo.to_file_id 
from 
  file, 
  (
    select 
      from_file_digest, 
      file_id as to_file_id
    from 
      file,
       non_dicom_edit_compare 
    where 
      to_file_digest = digest
      and subprocess_invocation_id = ?
  ) as foo
where 
  from_file_digest = digest;