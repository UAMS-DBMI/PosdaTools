-- Name: PixelInfoBySopInstance
-- Schema: posda_files
-- Columns: ['file_id', 'file', 'file_offset', 'size', 'bits_stored', 'bits_allocated', 'pixel_representation', 'number_of_frames', 'samples_per_pixel', 'pixel_rows', 'pixel_columns', 'photometric_interpretation', 'planar_configuration', 'modality']
-- Args: ['sop_instance_uid']
-- Tags: []
-- Description: Get pixel descriptors for a particular image id
-- 

select
  f.file_id, root_path || '/' || rel_path as file, file_offset, size, 
  bits_stored, bits_allocated, pixel_representation, number_of_frames,
  samples_per_pixel, pixel_rows, pixel_columns, photometric_interpretation,
  planar_configuration, modality
from
  file_image f natural join image natural join unique_pixel_data
  join pixel_location pl using(unique_pixel_data_id), 
  file_location fl natural join file_storage_root
  natural join file_series 
where
  pl.file_id = fl.file_id
  and f.file_id = pl.file_id
  and f.file_id in (
    select distinct file_id
    from file_sop_common where sop_instance_uid = ?
  )
