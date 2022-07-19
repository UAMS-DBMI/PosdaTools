-- Name: GetVeryBasicFileInfo
-- Schema: posda_files
-- Columns: ['file_id', 'file_type']
-- Args: ['file_id']
-- Tags: ['temp_mpr']
-- Description: Basic file information for a file
-- 

select
  distinct file_id, file_type
from
  file
where
  file_id = ?