-- Name: GetMaxFileIdForDicomEditCompare
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root
--

select
  max(file_id) as file_id
from
  file where digest in (
  select to_file_digest as digest from dicom_edit_compare 
  where subprocess_invocation_id = ?
)
