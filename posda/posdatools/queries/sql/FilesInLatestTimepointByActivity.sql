-- Name: FilesInLatestTimepointByActivity
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['activity_id']
-- Tags: []
-- Description: View filepaths for the files in the latest Actitivy TP for the specified activity id
-- 

select
  file_id
from
  activity_timepoint_file
where
  activity_timepoint_id =  (select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ? )
