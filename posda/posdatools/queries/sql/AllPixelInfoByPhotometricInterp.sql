-- Name: AllPixelInfoByPhotometricInterp
-- Schema: posda_files
-- Columns: ['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'modality']
-- Args: ['bits_allocated']
-- Tags: []
-- Description: Get pixel descriptors for all files
-- 

select
  f.file_id as file_id, root_path || '/' || rel_path as file,
  file_offset, size, modality,
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation
from
  file_image f natural join image natural join unique_pixel_data
  natural join file_series
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
  select distinct file_id
  from
    ctp_file natural join file_image natural join image
  where visibility is null and photometric_interpretation = ?
)
