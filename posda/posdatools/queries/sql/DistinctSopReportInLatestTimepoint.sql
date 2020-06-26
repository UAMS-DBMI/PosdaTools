-- Name: DistinctSopReportInLatestTimepoint
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'modality', 'sop_instance_uid']
-- Args: ['activity_id']
-- Tags: []
-- Description: Report on all Sops in latest activity timepoint for activity
--

select 
  distinct patient_id, series_instance_uid, modality, sop_instance_uid
from file_sop_common natural join 
  activity_timepoint_file natural join file_patient natural join
  file_series
where activity_timepoint_id in (
  select max(activity_timepoint_id) as activity_timepoint_id
  from activity_timepoint where activity_id = ?
)
order by patient_id, series_instance_uid, modality, sop_instance_uid