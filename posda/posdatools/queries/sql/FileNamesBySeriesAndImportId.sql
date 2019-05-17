-- Name: FileNamesBySeriesAndImportId
-- Schema: posda_files
-- Columns: ['file_id', 'file_name']
-- Args: ['import_event_id', 'series_instance_uid']
-- Tags: ['downloads_by_date', 'import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select file_id, file_name
from file_import natural join import_event natural join file_series
where import_event_id = ? and series_instance_uid = ?