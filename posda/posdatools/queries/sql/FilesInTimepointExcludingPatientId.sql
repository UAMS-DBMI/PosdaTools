-- Name: FilesInTimepointExcludingPatientId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['activity_timepoint_id', 'patient_id not like']
-- Tags: ['activity_timepoint']
-- Description: Get list of files in timepoint excluding files with specified patient_id
--

select 
  distinct file_id
from 
  activity_timepoint_file natural join file_patient
where
  activity_timepoint_id = ? and
  patient_id not like ?
