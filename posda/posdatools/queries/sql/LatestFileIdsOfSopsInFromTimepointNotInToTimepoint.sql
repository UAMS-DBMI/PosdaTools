-- Name: LatestFileIdsOfSopsInFromTimepointNotInToTimepoint
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['from_timepoint', 'to_timepoint']
-- Tags: ['timepoint_compare']
-- Description: Get a list of SOP instance uids in one timepoint but not in another
--

select file_id from (select sop_instance_uid, max(file_id) as file_id from file_sop_common
where sop_instance_uid in (select 
  sop_instance_uid 
  from activity_timepoint_file natural join file_sop_common
  where activity_timepoint_id = ?
except
  select sop_instance_uid 
  from activity_timepoint_file natural join file_sop_common
  where activity_timepoint_id = ?
)
group by sop_instance_uid) as foo