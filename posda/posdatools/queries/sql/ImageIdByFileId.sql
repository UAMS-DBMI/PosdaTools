-- Name: ImageIdByFileId
-- Schema: posda_files
-- Columns: ['file_id', 'image_id']
-- Args: ['file_id']
-- Tags: ['by_file_id', 'image_id', 'posda_files']
-- Description: Get image_id for file_id 
-- 

select
  distinct file_id, image_id
from
  file_image
where
  file_id = ?
