-- Name: CreateDicomEditCompareDisposition
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id', 'process_pid', 'dest_dir']
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Create an entry in dicom_edit_compare_disposition
-- 
-- From script only.  Don't run from user interface (needs valid subprocess_invocation_id)

insert into dicom_edit_compare_disposition(
  subprocess_invocation_id, start_creation_time, current_disposition, process_pid, dest_dir
)values (
  ?, now(), 'Starting Up', ?, ?
)