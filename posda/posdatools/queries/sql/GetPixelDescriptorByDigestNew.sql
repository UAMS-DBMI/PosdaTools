-- Name: GetPixelDescriptorByDigestNew
-- Schema: posda_files
-- Columns: ['samples_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'pixel_data_offset', 'pixel_data_length', 'path']
-- Args: ['pixel_data_digest']
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
  pixel_data_offset, 
  pixel_data_length,
  root_path || '/' || rel_path as path
from
  image natural join file_image
  natural join dicom_file natural join file_location
  natural join file_storage_root where pixel_data_digest = ?
limit 1