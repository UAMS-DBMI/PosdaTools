-- Name: GetNonDicomEditCompareToFiles
-- Schema: posda_files
-- Columns: ['path', 'file_id', 'collection', 'visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility
-- 
-- NB: Before import:
--        There should be no file_id (i.e. file has not been imported)  And there should be no collection.
--        (i.e. normally file_id, collection, and visibility are all null).

select 
  path,
  file_id,
  collection,
  visibility
from 
  (
    select to_file_path as path, to_file_digest as digest
    from non_dicom_edit_compare
    where subprocess_invocation_id = ?
  ) as foo natural left join
  file natural left join non_dicom_file