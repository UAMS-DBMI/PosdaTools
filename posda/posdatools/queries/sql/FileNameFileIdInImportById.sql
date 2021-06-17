-- Name: FileNameFileIdInImportById
-- Schema: posda_files
-- Columns: ['file_name', 'file_id']
-- Args: ['import_event_id']
-- Tags: ['nifti']
-- Description: Get the ImportEventId of an import based on import_comment
-- 

select
  file_name, file_id
from
  file_import
where
  import_event_id = ?