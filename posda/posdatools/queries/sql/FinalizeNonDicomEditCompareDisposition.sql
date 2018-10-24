-- Name: FinalizeNonDicomEditCompareDisposition
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_edit']
-- Description: Update an entry in dicom_edit_compare_disposition to indicate its done.
-- 
-- From script only.  Don't run from user interface (needs valid subprocess_invocation_id)

update non_dicom_edit_compare_disposition set
  end_creation_time = now(),
  last_updated = now(),
  current_disposition = 'Comparisons Complete'
where
  subprocess_invocation_id = ?
