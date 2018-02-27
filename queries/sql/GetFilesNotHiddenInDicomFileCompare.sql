-- Name: GetFilesNotHiddenInDicomFileCompare
-- Schema: posda_files
-- Columns: ['from_file_digest']
-- Args: ['command_file_id', 'command_file_id_1', 'command_file_id_2']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get Files not hidden but replacement imported

select
  distinct from_file_digest
from
  dicom_edit_compare
where
  from_file_digest in 
  (
    select from_file_digest from 
    (
      select distinct from_file_digest 
      from dicom_edit_compare dec, file f natural join ctp_file
      where dec.from_file_digest = f.digest and visibility is null and subprocess_invocation_id = ?
      except
      select from_file_digest from dicom_edit_compare dec
      where not exists
      (
        select file_id from file f where dec.to_file_digest = f.digest
       ) 
       and subprocess_invocation_id = ?
    ) as foo
  )
  and subprocess_invocation_id = ?
