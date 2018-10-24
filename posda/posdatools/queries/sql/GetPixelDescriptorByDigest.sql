-- Name: GetPixelDescriptorByDigest
-- Schema: posda_files
-- Columns: ['samples_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'file_offset', 'path']
-- Args: ['pixel_digest']
-- Tags: ['meta', 'test', 'hello']
-- Description: Find Duplicated Pixel Digest

select
  samples_per_pixel, 
  number_of_frames, 
  pixel_rows,
  pixel_columns,
  bits_stored,
  bits_allocated,
  high_bit, 
  file_offset,
  root_path || '/' || rel_path as path
from
  image
  natural join unique_pixel_data
  natural join pixel_location
  join file_location using (file_id)
  join file_storage_root using (file_storage_root_id)
where digest = ?
limit 1