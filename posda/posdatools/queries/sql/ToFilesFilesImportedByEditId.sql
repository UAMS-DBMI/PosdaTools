-- Name: ToFilesFilesImportedByEditId
-- Schema: posda_files
-- Columns: ['files_imported']
-- Args: ['subprocess_invocation_id']
-- Tags: ['adding_ctp', 'find_patients', 'series_selection', 'check_edits']
-- Description: Get List of visible patients with CTP data

select
  count(distinct file_id) as files_imported
from (
    select distinct file_id from file f, dicom_edit_compare dec
     where f.digest = dec.to_file_digest and 
        subprocess_invocation_id = ?
  ) as foo
