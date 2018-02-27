-- Name: GetDicomEditCompareDisposition
-- Schema: posda_files
-- Columns: ['number_edits_scheduled', 'number_compares_with_diffs', 'number_compares_without_diffs', 'current_disposition', 'dest_dir']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Retrieve entries from patient_mapping table

select
  number_edits_scheduled,
  number_compares_with_diffs,
  number_compares_without_diffs,
  current_disposition,
  dest_dir
from
  dicom_edit_compare_disposition
where
  subprocess_invocation_id = ?
  