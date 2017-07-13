-- Name: PixelInfoByImageId
-- Schema: posda_files
-- Columns: ['file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation']
-- Args: ['image_id']
-- Tags: []
-- Description: Get pixel descriptors for a particular image id
-- 

select
  root_path || '/' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  image natural join unique_pixel_data natural join pixel_location
  natural join file_location natural join file_storage_root
where image_id = ?
