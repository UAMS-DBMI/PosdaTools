-- Name: SopInActivity
-- Schema: posda_files
-- Columns: ['file_id', 'instance_number']
-- Args: ['sop_instance_uid', 'activity_timepoint_id']
-- Tags: ['FileId']
-- Description: Get the file_id of a Sop in an Activity
-- 

select
  file_id, instance_number
from 
  file_sop_common natural join activity_timepoint_file
where
  sop_instance_uid = ?
  and activity_timepoint_id = (
    select max(activity_timepoint_id) from activity_timepoint
    where activity_timepoint_id = ?
  )