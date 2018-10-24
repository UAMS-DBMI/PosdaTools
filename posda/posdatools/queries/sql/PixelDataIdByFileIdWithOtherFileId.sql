-- Name: PixelDataIdByFileIdWithOtherFileId
-- Schema: posda_files
-- Columns: ['file_id', 'image_id', 'unique_pixel_data_id', 'other_file_id']
-- Args: ['file_id']
-- Tags: ['by_file_id', 'duplicates', 'pixel_data_id', 'posda_files']
-- Description: Get unique_pixel_data_id for file_id 
-- 

select
  distinct f.file_id as file_id, image_id, unique_pixel_data_id, 
  l.file_id as other_file_id
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location l using(unique_pixel_data_id)
where
  f.file_id = ?
