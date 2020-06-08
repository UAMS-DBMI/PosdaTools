-- Name: FilesInTimepointWithPatientId
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints']
-- Description:   Get files in timepoint
--

select
  distinct file_id, patient_id
from
  activity_timepoint_file natural join file_patient
where
  activity_timepoint_id = ?