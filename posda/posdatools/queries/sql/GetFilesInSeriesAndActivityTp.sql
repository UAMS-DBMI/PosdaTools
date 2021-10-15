-- Name: GetFilesInSeriesAndActivityTp
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['series_instance_uid', 'activity_timepoint_id']
-- Tags: ['queries']
-- Description: Files in a series in latest timepoint of activity
-- 

select
  file_id
from
  file_series natural join activity_timepoint_file
where
  series_instance_uid = ? and
  activity_timepoint_id = ?