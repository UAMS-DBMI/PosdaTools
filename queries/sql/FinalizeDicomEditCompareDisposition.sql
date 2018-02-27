-- Name: FinalizeDicomEditCompareDisposition
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id']
-- Tags: ['bills_test', 'adding_ctp', 'for_scripting']
-- Description: Update an entry in dicom_edit_compare_disposition to indicate its done.
-- 
-- From script only. Don't run from user interface (needs valid subprocess_invocation_id)

update dicom_edit_compare_disposition set
  end_creation_time = now(),
  current_disposition = 'Comparisons Complete'
where
  subprocess_invocation_id = ?