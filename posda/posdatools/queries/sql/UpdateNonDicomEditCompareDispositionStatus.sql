-- Name: UpdateNonDicomEditCompareDispositionStatus
-- Schema: posda_files
-- Columns: []
-- Args: ['current_disposition', 'subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Update status of an entry in dicom_edit_compare_disposition
-- 
-- From script only.  Don't run from user interface (needs valid subprocess_invocation_id)

update non_dicom_edit_compare_disposition set
  current_disposition = ?,
  last_updated = now()
where
  subprocess_invocation_id = ?
