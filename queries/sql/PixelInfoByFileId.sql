-- Name: PixelInfoByFileId
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
  file_image f natural join image natural join unique_pixel_data
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  f.file_id = ? and pl.file_id = fl.file_id
  and f.file_id = pl.file_id
