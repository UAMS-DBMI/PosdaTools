-- Name: ListOfFirstNFilesByImportEventId
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['import_event_id', 'limit']
-- Tags: ['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select
  file_id, root_path || '/' || rel_path as path
from
  file_storage_root natural join file_location
where file_id in (
  select file_id from file_import where import_event_id = ?
  limit ?
)