-- Name: UpdateNonDicomEditCompareDisposition
-- Schema: posda_files
-- Columns: []
-- Args: ['number_edits_scheduled', 'number_compares_with_diffs', 'number_compares_without_diffs', 'subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_edit']
-- Description: Update an entry in dicom_edit_compare_disposition
-- 
-- From script only.  Don't run from user interface (needs valid subprocess_invocation_id)

update non_dicom_edit_compare_disposition set
  num_edits_scheduled = ?,
  num_compares_with_diffs = ?,
  num_compares_without_diffs = ?,
  current_disposition = 'Comparisons In Progress',
  last_updated = now()
where
  subprocess_invocation_id = ?
