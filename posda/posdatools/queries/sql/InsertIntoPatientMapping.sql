-- Name: InsertIntoPatientMapping
-- Schema: posda_files
-- Columns: []
-- Args: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'site_code']
-- Tags: ['adding_ctp', 'mapping_tables', 'insert_pat_mapping', 'non_dicom_edit']
-- Description: Make an entry into the patient_mapping table


insert into patient_mapping(
  from_patient_id, to_patient_id,  to_patient_name,
  collection_name, site_name, batch_number,
  diagnosis_date,  baseline_date, date_shift,
  uid_root, site_code
) values (
  ?, ?, ?,
  ?, ?, ?,
  ?, ?, ?,
  ?, ?)