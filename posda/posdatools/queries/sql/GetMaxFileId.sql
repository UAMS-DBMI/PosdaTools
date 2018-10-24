-- Name: GetMaxFileId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: []
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select
  max(file_id) as file_id
from
  file
