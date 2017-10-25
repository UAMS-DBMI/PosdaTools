-- Name: GetVisibilityByFileId
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['file_id']
-- Tags: ['ImageEdit', 'NotInteractive']
-- Description: Get Visibility for a file by file_id
-- 

select
  file_id, visibility
from
   ctp_file
where
   file_id = ?
