-- Name: GetLoadPathByImportEventIdAndFileId
-- Schema: posda_files
-- Columns: ['file_name']
-- Args: ['file_id', 'import_event_id']
-- Tags: ['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select file_name from file_import where file_id = ? and import_event_id = ?