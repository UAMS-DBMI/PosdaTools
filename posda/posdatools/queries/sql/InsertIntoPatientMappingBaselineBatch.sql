-- Name: InsertIntoPatientMappingBaselineBatch
-- Schema: posda_files
-- Columns: []
-- Args: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'date_shift']
-- Tags: ['adding_ctp', 'mapping_tables', 'insert_pat_mapping']
-- Description: Make an entry into the patient_mapping table with batch, diagnosis_date, and baseline_date

insert into patient_mapping(
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  diagnosis_date,
  baseline_date) values (
  ?, ?, ?, ?, ?, ?, ?, ?)