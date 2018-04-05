-- Name: GetFileStorageRootByStorageClass
-- Schema: posda_files
-- Columns: ['root_path']
-- Args: ['storage_class']
-- Tags: ['NotInteractive', 'used_in_import_edited_files', 'used_in_check_circular_view']
-- Description: Get root path for a storage_class

select
  root_path
from
  file_storage_root
where 
 storage_class = ?
  and current