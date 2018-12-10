-- Name: CreateComparePublicToPosdaInstance
-- Schema: posda_files
-- Columns: []
-- Args: ['num_sops']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Create an entry in dicom_edit_compare_disposition
-- 
-- From script only.  Don't run from user interface (needs valid subprocess_invocation_id)

insert into compare_public_to_posda_instance(
  when_compare_started, status_of_compare, number_of_sops
)values (
  now(), 'Starting Up', ?
)