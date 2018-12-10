-- Name: FileIdsByActivityTimepointId
-- Schema: posda_queries
-- Columns: ['file_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoint_support']
-- Description: Get files in an activity_timepoint

select
 file_id
from
  activity_timepoint_file
where
  activity_timepoint_id = ?