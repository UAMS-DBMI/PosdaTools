-- Name: InsertInitialPatientStatus
-- Schema: posda_files
-- Columns: None
-- Args: ['patient_id', 'status']
-- Tags: ['Insert', 'NotInteractive', 'PatientStatus']
-- Description: Insert Initial Patient Status
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into patient_import_status(
  patient_id, patient_import_status
) values (?, ?)
