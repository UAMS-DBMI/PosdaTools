-- Name: PixelTypesWithNoGeo
-- Schema: posda_files
-- Columns: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration']
-- Args: []
-- Tags: ['find_pixel_types', 'image_geometry', 'posda_files']
-- Description: Get pixel types with no geometry
-- 

select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration
from
  image i where image_id not in (
    select image_id from image_geometry g where g.image_id = i.image_id
  )
order by photometric_interpretation
