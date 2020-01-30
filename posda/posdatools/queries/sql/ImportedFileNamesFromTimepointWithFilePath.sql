-- Name: ImportedFileNamesFromTimepointWithFilePath
-- Schema: posda_files
-- Columns: ['file_name', 'stored_path']
-- Args: ['activity_timepoint_id']
-- Tags: ['file_name']
-- Description: Get list of imported file_name and stored_path from an activity timepoint
-- 

select
  distinct  file_name, root_path || '/' || l.rel_path as stored_path
from
  file_import join file_location l using(file_id) join file_storage_root using(file_storage_root_id)
where
  file_id in (
    select file_id 
    from activity_timepoint_file 
    where activity_timepoint_id = ?
)