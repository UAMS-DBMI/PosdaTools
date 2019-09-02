-- Name: FindHiddenFromFiles
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['subprocess_invocation_id']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets a list of "to" files in an DICOM edit compare which been hidden
-- 
-- (by file_digest)
--

select
  file_id
from
  file natural left join ctp_file
where visibility is not null and digest in ( 
  select from_file_digest as digest from dicom_edit_compare where subprocess_invocation_id = ?)