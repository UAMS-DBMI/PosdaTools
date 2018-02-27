-- Name: UpdateDicomEditCompareDispositionStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['current_disposition', 'subprocess_invocation_id']
-- Tags: ['bills_test', 'adding_ctp', 'for_scripting']
-- Description: Update status of an entry in dicom_edit_compare_disposition
-- 
-- From script only. Don't run from user interface (needs valid subprocess_invocation_id)

update dicom_edit_compare_disposition set
  current_disposition = ?,
  last_updated = now()
where
  subprocess_invocation_id = ?