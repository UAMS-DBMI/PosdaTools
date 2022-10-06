-- Name: InsertPathologyPatientMapping
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id','patient_id','original_file_name', 'collection_name','site_name']
-- Tags: ['pathology','patient_mapping']
-- Description: Insert a patient mapping record for each file in a pathology collection
--

insert into pathology_patient_mapping values (?,?,?,?,?) on conflict (file_id) do update set patient_id = Excluded.patient_id, original_file_name = Excluded.original_file_name, collection_name = Excluded.collection_name, site_name = Excluded.site_name;
