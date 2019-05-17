-- Name: GetEditStatusExt
-- Schema: posda_files
-- Columns: ['id', 'start_creation_time', 'duration', 'to_edit', 'changed', 'not_changed', 'disposition', 'dest_dir', 'command_line', 'crash']
-- Args: []
-- Tags: ['adding_ctp', 'find_patients', 'series_selection', 'check_edits', 'testing_edit_objects', 'edit_status', 'crash']
-- Description: Get List of visible patients with CTP data

select
  subprocess_invocation_id as id,
  start_creation_time, end_creation_time - start_creation_time as duration,
  number_edits_scheduled as to_edit,
  number_compares_with_diffs as changed,
  number_compares_without_diffs as not_changed,
  current_disposition as disposition,
  dest_dir, command_line, b.crash
from
  dicom_edit_compare_disposition  join subprocess_invocation using (subprocess_invocation_id)
  join background_subprocess b using(subprocess_invocation_id)
order by start_creation_time desc