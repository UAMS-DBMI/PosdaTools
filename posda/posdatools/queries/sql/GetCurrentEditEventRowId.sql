-- Name: GetCurrentEditEventRowId
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_import_edited_files']
-- Description: Get current dicom_edit_event_id
-- For use in scripts
-- Not really intended for interactive use
-- 

select currval('dicom_edit_event_dicom_edit_event_id_seq') as id