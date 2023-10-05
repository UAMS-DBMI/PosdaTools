-- Name: patient_id_and_collection_by_like_collection
-- Schema: posda_files
-- Columns: ['collection', 'patient_id']
-- Args: ['like_collection']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select distinct project_name as collection, patient_id from file_patient natural join ctp_file where project_name like ?