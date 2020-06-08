-- Name: MappedFilesInTimepointWithPatientId
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints']
-- Description:   Get files in timepoint
--

select
  distinct file_id, patient_id
from
  activity_timepoint_file natural join file_patient p
  where exists (
    select from_patient_id 
    from patient_mapping pm where pm.from_patient_id = p.patient_id
  ) and 
  activity_timepoint_id = ?