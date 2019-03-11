-- Name: GetPatientMappingByCollectionSite
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift', 'diagnosis_date', 'baseline_date', 'year_of_diagnosis', 'computed_shift']
-- Args: ['collection_name', 'site_name']
-- Tags: ['adding_ctp', 'for_scripting', 'patient_mapping', 'ACRIN-NSCLC-FDG-PET Curation']
-- Description: Retrieve entries from patient_mapping table

select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  '<' || diagnosis_date || '>' as diagnosis_date,
  '<' || baseline_date || '>' as baseline_date,
  date_shift,
  baseline_date - diagnosis_date as computed_shift
from
  patient_mapping
where collection_name = ? and site_name = ?
  
