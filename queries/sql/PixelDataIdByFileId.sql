-- Name: PixelDataIdByFileId
-- Schema: posda_files
-- Columns: ['file_id', 'image_id', 'unique_pixel_data_id']
-- Args: ['file_id']
-- Tags: ['by_file_id', 'pixel_data_id', 'posda_files']
-- Description: Get unique_pixel_data_id for file_id 
-- 

select
  distinct file_id, image_id, unique_pixel_data_id
from
  file_image natural join image
where
  file_id = ?
