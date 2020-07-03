-- Name: DistinctSopsInLatestTimepoint
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['activity_id']
-- Tags: []
-- Description: Find Series in Latest Timepoint which contain a SOP which:
--    - is not in the current timepoint
--    - is in some other activity
--

select 
  distinct sop_instance_uid
from file_sop_common natural join activity_timepoint_file
where activity_timepoint_id in (
  select max(activity_timepoint_id) as activity_timepoint_id
  from activity_timepoint where activity_id = ?
)