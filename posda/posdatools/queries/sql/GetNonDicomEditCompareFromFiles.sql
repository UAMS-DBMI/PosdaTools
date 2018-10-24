-- Name: GetNonDicomEditCompareFromFiles
-- Schema: posda_files
-- Columns: ['file_id', 'collection', 'visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Get a list of from files from the non_dicom_edit_compare table for a particular edit instance, with visibility
-- 
-- NB: collection will be null if there is no non_dicom_file row.  This shouldn't ever happen.  ever!  abort and investigate
--        visibility, on the other hand, should always be null.  

select 
  file_id,
  collection,
  visibility
from 
  file join non_dicom_file using(file_id)
where
  file_id in (
    select file_id from file f, non_dicom_edit_compare ndec
    where f.digest = ndec.from_file_digest and subprocess_invocation_id = ?
  )