-- Name: FileIdsByPatientAndActivity
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['patient_id', 'activity_id']
-- Tags: ['activity_timepoint']
-- Description: Get List of file_ids for patient in timepoint
-- 

select
  file_id
from
  activity_timepoint_file natural join file_patient
where
  patient_id = ?
  and activity_timepoint_id  = (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint where activity_id = ?
  )