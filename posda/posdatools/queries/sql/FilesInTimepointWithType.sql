-- Name: FilesInTimepointWithType
-- Schema: posda_files
-- Columns: ['file_id', 'file_type']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints', 'export_event']
-- Description:   Get files in timepoint
--

select
  distinct file_id, file_type
from
  activity_timepoint_file natural join file
where
  activity_timepoint_id = ?