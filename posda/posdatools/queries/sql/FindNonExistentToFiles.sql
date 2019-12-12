-- Name: FindNonExistentToFiles
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description:  Gets a list of "to" files in an DICOM edit compare which have not been imported
-- 
-- (by file_digest)
--

select
  to_file_digest
from
  dicom_edit_compare dec
where
  subprocess_invocation_id = ?
  and not exists(
    select file_id from file f where f.digest = dec.to_file_digest
  )