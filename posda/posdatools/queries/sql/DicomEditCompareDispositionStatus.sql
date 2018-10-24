-- Name: DicomEditCompareDispositionStatus
-- Schema: posda_files
-- Columns: ['id', 'status', 'started_at', 'run_time', 'since_update', 'pid', 'total_edits', 'remaining']
-- Args: []
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Status of entries in dicom_edit_comparison

select 
  subprocess_invocation_id as id, 
  current_disposition as status,
  date_trunc('minute', start_creation_time) as started_at,
  date_trunc('second', last_updated - start_creation_time) as run_time,
  date_trunc('second', now() - last_updated) as since_update, 
  process_pid as pid,
  number_edits_scheduled as total_edits,
  number_edits_scheduled - (number_compares_with_diffs + number_compares_without_diffs) as remaining
from
dicom_edit_compare_disposition