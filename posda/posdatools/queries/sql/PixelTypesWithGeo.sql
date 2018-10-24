-- Name: PixelTypesWithGeo
-- Schema: posda_files
-- Columns: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'iop']
-- Args: []
-- Tags: ['find_pixel_types', 'image_geometry', 'posda_files']
-- Description: Get distinct pixel types with geometry
-- 

select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop
from
  image natural join image_geometry
order by photometric_interpretation
