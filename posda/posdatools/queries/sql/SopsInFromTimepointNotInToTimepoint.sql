-- Name: SopsInFromTimepointNotInToTimepoint
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['from_timepoint', 'to_timepoint']
-- Tags: ['timepoint_compare']
-- Description: Get a list of SOP instance uids in one timepoint but not in another
--

select 
  sop_instance_uid 
  from activity_timepoint_file natural join file_sop_common
  where activity_timepoint_id = ?
except
  select sop_instance_uid 
  from activity_timepoint_file natural join file_sop_common
  where activity_timepoint_id = ?