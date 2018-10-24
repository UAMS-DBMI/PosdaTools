-- Name: AddPatientAge
-- Schema: posda_files
-- Columns: []
-- Args: ['age', 'file_id']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

update file_patient set
  patient_age = ?
where file_id = ?