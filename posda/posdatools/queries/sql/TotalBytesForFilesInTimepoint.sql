-- Name: TotalBytesForFilesInTimepoint
-- Schema: posda_files
-- Columns: ['total_bytes']
-- Args: ['activity_timepoint_id']
-- Tags: ['file_size']
-- Description: Total bytes in all files in activity_timepoint
-- 

select
  sum(size) as total_bytes
from file
where file_id in (
  select file_id from activity_timepoint_file where activity_timepoint_id = ?)