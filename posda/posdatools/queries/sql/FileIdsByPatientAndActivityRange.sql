-- Name: FileIdsByPatientAndActivityRange
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['patient_id', 'first_activity', 'last_activity']
-- Tags: ['activity_timepoint']
-- Description: Get List of file_ids for patient in timepoint
-- 

select
  distinct file_id
from
  activity_timepoint_file natural join file_patient
where
  patient_id = ?
  and activity_timepoint_id  in (
    select max(activity_timepoint_id) as activity_timepoint_id
    from activity_timepoint where activity_id in (
     select activity_id from activity where activity_id >= ? and activity_id <= ?
    )
  )