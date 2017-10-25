-- Name: PixelTypesWithSlopeCT
-- Schema: posda_files
-- Columns: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'planar_configuration', 'modality', 'slope', 'intercept', 'count']
-- Args: []
-- Tags: []
-- Description: Get distinct pixel types
-- 

select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept,
  count(*)
from
  image natural join file_image natural join file_series
  natural join file_slope_intercept natural join slope_intercept
where
  modality = 'CT'
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept
order by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_representation,
  planar_configuration,
  modality,
  slope,
  intercept
