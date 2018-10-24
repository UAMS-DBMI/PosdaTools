-- Name: FileIdByPixelType
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration']
-- Tags: ['all', 'find_pixel_types', 'posda_files']
-- Description: Get distinct pixel types
-- 

select
  distinct file_id
from
  image natural join file_image
where
  photometric_interpretation = ? and
  samples_per_pixel = ? and
  bits_allocated = ? and
  bits_stored = ? and
  high_bit = ? and
  (pixel_representation = ?  or pixel_representation is null) and
  (planar_configuration = ? or planar_configuration is null)
limit 100