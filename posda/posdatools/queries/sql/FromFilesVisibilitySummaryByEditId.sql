-- Name: FromFilesVisibilitySummaryByEditId
-- Schema: posda_files
-- Columns: ['visibility', 'num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'find_patients', 'series_selection', 'check_edits']
-- Description: Get List of visible patients with CTP data

select
  distinct visibility, count(distinct file_id) as num_files
from ctp_file
where 
  file_id in (
    select distinct file_id from file f, dicom_edit_compare dec
     where f.digest = dec.from_file_digest and 
        subprocess_invocation_id = ?
  )
group by visibility