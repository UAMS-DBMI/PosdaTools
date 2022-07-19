-- Name: FileNameFileIdPathInImportById
-- Schema: posda_files
-- Columns: ['file_name', 'file_id', 'file_path']
-- Args: ['import_event_id']
-- Tags: ['nifti']
-- Description: Get the ImportEventId of an import based on import_comment
-- 

select
  fi.file_name as submitted_file, file_id,
  root_path || '/' || fl.rel_path as file_path
from
  file_import fi join file_location fl using (file_id) join file_storage_root using(file_storage_root_id)
where
  import_event_id = ?