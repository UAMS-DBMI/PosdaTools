-- Name: ManifestsByDate
-- Schema: posda_files
-- Columns: ['file_id', 'import_time', 'size', 'path', 'alt_path']
-- Args: ['from', 'to']
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
  import_time >?and import_time < ? and
  file_type like '%ASCII%' and
  l.rel_path like '%/Manifests/%'
order by import_time