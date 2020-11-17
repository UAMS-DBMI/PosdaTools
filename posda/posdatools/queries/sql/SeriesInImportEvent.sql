-- Name: SeriesInImportEvent
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['import_event_id']
-- Tags: ['va', 'phi_scan']
-- Description: Get all series in an import_event_id
-- 

select
  distinct series_instance_uid
from
  file_import natural join file_series
where
  import_event_id = ?