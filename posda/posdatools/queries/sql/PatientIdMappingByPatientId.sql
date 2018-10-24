-- Name: PatientIdMappingByPatientId
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root']
-- Args: ['from_patient_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_phi', 'non_dicom_edit']
-- Description: Simple Phi Report with Meta Quotes

select
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name,
  batch_number, diagnosis_date, baseline_date, date_shift, uid_root
from 
  patient_mapping
where
  from_patient_id = ?