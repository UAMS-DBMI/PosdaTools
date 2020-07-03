-- Name: ActivityCrosstalkSop
-- Schema: posda_files
-- Columns: ['activity_id', 'brief_description', 'when_created', 'who_created', 'when_closed', 'third_party_analysis_url', 'num_timepoints', 'num_files']
-- Args: ['activity_id']
-- Tags: ['activity_crosstalk']
-- Description: Get list of activities with potential cross talk based on shared files
--

select
  distinct activity_id, brief_description, a.when_created, a.who_created, when_closed,
  third_party_analysis_url, count(distinct activity_timepoint_id) as num_timepoints,
  count(distinct file_id) as num_files
from
  activity a join activity_timepoint using (activity_id) natural join activity_timepoint_file 
  natural join file_sop_common
where sop_instance_uid in (
  select 
    distinct sop_instance_uid
  from
    file_sop_common natural join activity_timepoint_file natural join activity_timepoint
  where activity_id = ?
)
group by activity_id, brief_description, a.when_created, a.who_created, when_closed,
  third_party_analysis_url
order by when_created