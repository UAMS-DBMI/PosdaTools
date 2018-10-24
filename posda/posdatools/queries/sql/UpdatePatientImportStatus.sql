-- Name: UpdatePatientImportStatus
-- Schema: posda_files
-- Columns: None
-- Args: ['patient_id', 'status']
-- Tags: ['NotInteractive', 'PatientStatus', 'Update']
-- Description: Update Patient Status
-- For use in scripts
-- Not really intended for interactive use
-- 

update patient_import_status set 
  patient_import_status = ?
where patient_id = ?
