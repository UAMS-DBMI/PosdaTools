-- Name: PixelTypesWithGeoRGB
-- Schema: posda_files
-- Columns: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'iop', 'num_images']
-- Args: []
-- Tags: ['find_pixel_types', 'image_geometry', 'posda_files', 'rgb']
-- Description: Get distinct pixel types with geometry and rgb
-- 

select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  iop, count(distinct image_id) as num_images
from
  image natural left join image_geometry
where
  photometric_interpretation = 'RGB'
group by photometric_interpretation,
  samples_per_pixel, bits_allocated, bits_stored, high_bit, pixel_representation,
  planar_configuration, iop
order by photometric_interpretation
