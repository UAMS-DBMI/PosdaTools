-- Name: GetPatientsForFilesInTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['export_event']
-- Description:  get the export_event_id of a newly created export_event
--

select
  distinct file_id, patient_id
from
  file_patient
where 
  file_id in (
  select file_id
  from activity_timepoint_file
  where activity_timepoint_id = ?
)