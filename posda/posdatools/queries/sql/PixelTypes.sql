-- Name: PixelTypes
-- Schema: posda_files
-- Columns: ['photometric_interpretation', 'samples_per_pixel', 'bits_allocated', 'bits_stored', 'high_bit', 'is_multi_frame', 'pixel_representation', 'planar_configuration', 'modality', 'dicom_file_type', 'count']
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
  coalesce(number_of_frames,1) > 1 as is_multi_frame,
  pixel_representation,
  planar_configuration,
  modality,
  dicom_file_type,
  count(distinct file_id)
from
  image natural join file_image natural join file_series
  natural join dicom_file
group by
  photometric_interpretation,
  samples_per_pixel,
  bits_allocated,
  bits_stored,
  high_bit,
  is_multi_frame,
  pixel_representation,
  planar_configuration,
  modality,
  dicom_file_type
order by
  count desc