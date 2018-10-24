-- Name: GetPatientMapping
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'computed_shift']
-- Args: []
-- Tags: ['adding_ctp', 'for_scripting', 'patient_mapping']
-- Description: Retrieve entries from patient_mapping table

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
  baseline_date - diagnosis_date + interval '1 day' as computed_shift
from
  patient_mapping
  