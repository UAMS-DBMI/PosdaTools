-- Name: WindowLevelByPixelType
-- Schema: posda_files
-- Columns: ['window_width', 'window_center', 'count']
-- Args: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'pixel_representation', 'modality']
-- Tags: ['all', 'find_pixel_types', 'posda_files']
-- Description: Get distinct pixel types
-- 

select 
  distinct window_width, window_center, count(*)
from (select
    distinct photometric_interpretation,
    samples_per_pixel,
    bits_allocated,
    bits_stored,
    high_bit,
    coalesce(number_of_frames,1) > 1 as is_multi_frame,
    pixel_representation,
    planar_configuration,
    modality,
    file_id
  from
    image natural join file_image natural join file_series
  ) as foo natural join file_win_lev natural join window_level
where
  photometric_interpretation = ? and
  samples_per_pixel = ? and
  bits_allocated = ? and
  bits_stored = ? and
  high_bit = ? and
  pixel_representation = ? and
  modality = ?
group by window_width, window_center
