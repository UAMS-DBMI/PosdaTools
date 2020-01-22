-- Name: GetCountOfUnimportedFilesInEdit
-- Schema: posda_files
-- Columns: ['num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root
--

select
  count(distinct to_file_digest) as num_files
from
  dicom_edit_compare dec
where 
  subprocess_invocation_id = ? and
  not exists (
    select file_id from file f
    where f.digest = dec.to_file_digest
  )

