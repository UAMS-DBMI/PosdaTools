-- Name: OverlappingPatients
-- Schema: posda_files
-- Columns: ['patient_id']
-- Args: ['activity_id_1', 'activity_id_2']
-- Tags: []
-- Description: Find List of patients common to two timepoints
-- 

select distinct(patient_id)
from file_patient where file_id in (
  select file_id from activity_timepoint_file where activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
)
intersect
select distinct(patient_id)
from file_patient where file_id in (
  select file_id from activity_timepoint_file where activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint
    where activity_id = ?
  )
)