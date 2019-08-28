-- Name: PatientsInActivityTimepoint
-- Schema: posda_files
-- Columns: ['patient_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoint']
-- Description: Get list of patients by activity_timepoint_id
--

select distinct patient_id
from file_patient natural left join ctp_file
where file_id in (
  select file_id from activity_timepoint_file
  where  activity_timepoint_id = ?
);