-- Name: AllManifestsByCollection
-- Schema: posda_files
-- Columns: ['file_id', 'import_time', 'size', 'path', 'alt_path']
-- Args: ['collection']
-- Tags: ['activity_timepoint_support', 'manifests']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct file_id, import_time, size, root_path || '/' || l.rel_path as path, i.file_name as alt_path
from
  file_location l join file_storage_root using(file_storage_root_id) 
  join file_import i using (file_id) natural join file join import_event using(import_event_id)
where
  file_id in (
    select distinct file_id from ctp_manifest_row where cm_collection = ?
  )