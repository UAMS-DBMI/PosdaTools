-- Name: SetLoadPathByImportEventIdAndFileId
-- Schema: posda_files
-- Columns: []
-- Args: ['file_name', 'file_id', 'import_event_id']
-- Tags: ['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

update file_import set file_name = ? where file_id = ? and import_event_id = ?