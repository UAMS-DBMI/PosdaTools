-- Name: GetNonDicomEditCompareDisposition
-- Schema: posda_files
-- Columns: ['num_edits_scheduled', 'num_compares_with_diffs', 'num_compares_without_diffs', 'current_disposition', 'dest_dir']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Retrieve entries from patient_mapping table

select
  num_edits_scheduled,
  num_compares_with_diffs,
  num_compares_without_diffs,
  current_disposition,
  dest_dir
from
  non_dicom_edit_compare_disposition
where
  subprocess_invocation_id = ?
  