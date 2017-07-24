-- Name: FastCurrentPatientStatii
-- Schema: posda_files
-- Columns: ['patient_id', 'patient_import_status']
-- Args: []
-- Tags: ['counts', 'count_queries', 'patient_status']
-- Description: Get the current status of all patients

select 
  patient_id,
  patient_import_status
from 
  patient_import_status
