-- Name: GetPatientMappingForSiteCode
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'site_code']
-- Args: ['site_code']
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
  date_trunc('day',diagnosis_date) as diagnosis_date,
  date_trunc('day',baseline_date) as baseline_date,
  date_shift,
  uid_root,
  site_code
from
  patient_mapping
where site_code = ?
  