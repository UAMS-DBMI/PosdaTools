-- Name: FilesInSeriesInImportEvent
-- Schema: posda_files
-- Columns: ['path']
-- Args: ['import_event_id', 'series_instance_uid']
-- Tags: ['va', 'phi_scan']
-- Description: Get all series in an import_event_id
-- 

select root_path || '/' || rel_path as path from
file_storage_root natural join file_location where file_id in (select
  distinct file_id
from
  file_import natural join file_series
where
  import_event_id = ? and series_instance_uid = ?)