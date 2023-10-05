-- Name: FindVisibleFromFiles
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description:  Gets a list of "from" files in an DICOM edit compare which have not  been hidden
-- 
-- (by file_digest)

select
  file_id
from
  file natural left join ctp_file
where visibility is null and digest in ( 
  select from_file_digest as digest from dicom_edit_compare where subprocess_invocation_id = ?)