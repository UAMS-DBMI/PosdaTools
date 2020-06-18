-- Name: ImportEventsInTimepoint
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_type', 'import_comment', 'import_time', 'num_files']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints']
-- Description:  Get files in timepoint
--

select 
  distinct import_event_id, import_type, import_comment, import_time, count(distinct file_id) as num_files
from
import_event natural join file_import where file_id in (
  select
    distinct file_id
  from
    activity_timepoint_file
  where
    activity_timepoint_id = ?
) group by import_event_id, import_type, import_comment, import_time