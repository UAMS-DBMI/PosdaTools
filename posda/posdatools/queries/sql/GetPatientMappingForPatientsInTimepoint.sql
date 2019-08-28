-- Name: GetPatientMappingForPatientsInTimepoint
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'site_code']
-- Args: ['activity_id']
-- Tags: ['adding_ctp', 'for_scripting', 'patient_mapping', 'activity_timepoint']
-- Description: Get patient mappings for patients in timepoint
--

select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  diagnosis_date,
  baseline_date,
  date_shift,
  uid_root,
  site_code
from
  patient_mapping
where from_patient_id in (
  select patient_id as from_patient_id
  from file_patient natural left join ctp_file
  where visibility is null and file_id in (
    select file_id from activity_timepoint_file
    where activity_timepoint_id in (
      select max(activity_timepoint_id) as activity_timepoint_id
      from activity_timepoint
      where activity_id = ?
    )
  )
)
  