-- Name: SetPatientMappingToInactive
-- Schema: posda_files
-- Columns: []
-- Args: ['upload_id']
-- Tags: ['mapping_tables', 'insert_pat_mapping', 'patient_mapping']
-- Description: Set a Patient Mapping upload to no longer active

update
  patient_mapping
set active = False
where upload_id = ?;
