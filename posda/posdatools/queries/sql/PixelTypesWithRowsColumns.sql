-- Name: PixelTypesWithRowsColumns
-- Schema: posda_files
-- Columns: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_rows', 'pixel_columns', 'number_of_frames', 'pixel_representation', 'planar_configuration', 'modality', 'count']
-- Args: []
-- Tags: ['all', 'find_pixel_types', 'posda_files']
-- Description: Get distinct pixel types
-- 

select
  distinct photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_rows,
  pixel_columns,
  number_of_frames,
  pixel_representation,
  planar_configuration,
  modality,
  count(*)
from
  image natural join file_image natural join file_series
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  pixel_rows,
  pixel_columns,
  number_of_frames,
  pixel_representation,
  planar_configuration,
  modality
order by
  count desc