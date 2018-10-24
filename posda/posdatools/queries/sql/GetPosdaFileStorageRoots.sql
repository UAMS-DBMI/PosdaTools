-- Name: GetPosdaFileStorageRoots
-- Schema: posda_files
-- Columns: ['id', 'root', 'current', 'storage_class']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Get Posda File Storage Roots

select
 file_storage_root_id as id, root_path as root, current, storage_class
from
  file_storage_root
