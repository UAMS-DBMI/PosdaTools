-- Name: FinalizeComparePublicToPosdaInstance
-- Schema: posda_files
-- Columns: []
-- Args: ['compare_public_to_posda_instance_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Update an entry in dicom_edit_compare_disposition
-- 
-- From script only.  Don't run from user interface (needs valid subprocess_invocation_id)

update compare_public_to_posda_instance set
  status_of_compare = 'Comparisons In Progress',
  when_compare_completed = now(),
  last_updated = now()
where
  compare_public_to_posda_instance_id = ?
