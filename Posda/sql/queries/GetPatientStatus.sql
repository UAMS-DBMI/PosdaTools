-- Name: GetPatientStatus
-- Schema: posda_files
-- Columns: ['status']
-- Args: ['patient_id']
-- Tags: ['NotInteractive', 'PatientStatus', 'Update']
-- Description: Get Patient Status

select
  patient_import_status as status
from
  patient_import_status
where
  patient_id = ?
