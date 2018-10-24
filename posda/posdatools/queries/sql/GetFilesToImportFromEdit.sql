-- Name: GetFilesToImportFromEdit
-- Schema: posda_files
-- Columns: ['subprocess_invocation_id', 'from_file_digest', 'to_file_digest', 'to_file_path']
-- Args: ['subprocess_invocation_id', 'subprocess_invocation_id_1', 'subprocess_invocation_id_2', 'limit']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select
  subprocess_invocation_id,
  from_file_digest,
  to_file_digest,
  to_file_path
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
      intersect
      select from_file_digest from dicom_edit_compare dec
      where not exists
      (
        select file_id from file f where dec.to_file_digest = f.digest
       ) 
       and subprocess_invocation_id = ?
    ) as foo
  )
  and subprocess_invocation_id = ?
limit ?