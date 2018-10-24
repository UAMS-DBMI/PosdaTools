-- Name: GetDicomEditCompareFromFiles
-- Schema: posda_files
-- Columns: ['file_id', 'project_name', 'visibility']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Get a list of from files from the dicom_edit_compare table for a particular edit instance, with visibility
-- 
-- NB: project_name will be null if there is no ctp_file row (so to hide the file you need to create a row with
--        project_name = 'UNKNOWN', site_name = 'UNKNOWN' and visibility = 'hidden' (if you want to hide the file)

select 
  file_id,
  project_name,
  visibility
from 
  file natural left join ctp_file
where
  file_id in (
    select file_id from file f, dicom_edit_compare dec
    where f.digest = dec.from_file_digest and subprocess_invocation_id = ?
  )