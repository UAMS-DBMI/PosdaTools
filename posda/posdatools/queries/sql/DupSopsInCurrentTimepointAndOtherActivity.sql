-- Name: DupSopsInCurrentTimepointAndOtherActivity
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['other_activity_id', 'activity_timepoint_id']
-- Tags: []
-- Description: Find files in specified old activity which have a dup sop in current activity
-- 

select 
  distinct file_id
from
  activity_timepoint_file natural join activity_timepoint
where
  activity_id = ? and file_id in (
    select distinct file_id
    from
      file_sop_common natural join 
      (
        select distinct sop_instance_uid, count(distinct file_id)
        from file_sop_common natural join activity_timepoint_file
        where activity_timepoint_id = ? group by sop_instance_uid
       )as foo 
    where count > 1
  )