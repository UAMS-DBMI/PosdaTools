-- Name: FileIdPathTimesLoadedCountsBySopInstance
-- Schema: posda_files
-- Columns: ['file_id', 'path', 'first_loaded', 'times_loaded', 'last_loaded']
-- Args: ['sop_instance_uid']
-- Tags: ['SeriesSendEvent', 'by_series', 'find_files', 'for_send']
-- Description: Get file path from id

select
  distinct file_id,
  root_path || '/' || file_location.rel_path as path,
  min(import_time) as first_loaded,
  count(distinct import_time) as times_loaded,
  max(import_time) as last_loaded
from
  file_location
  natural join file_storage_root
  join file_import using(file_id)
  join import_event using (import_event_id)
  natural join file_sop_common where sop_instance_uid = ?
group by file_id, path
order by first_loaded