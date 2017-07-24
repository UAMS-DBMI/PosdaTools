-- Name: DistinguishedDigests
-- Schema: posda_files
-- Columns: ['distinguished_pixel_digest', 'type_of_pixel_data', 'sample_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'pixel_mask', 'num_distinct_values', 'pixel_value', 'num_occurances']
-- Args: []
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: show series with distinguished digests and counts

select
   pixel_digest as distinguished_pixel_digest,
   type_of_pixel_data,
   sample_per_pixel,
   number_of_frames,
   pixel_rows,
   pixel_columns,
   bits_stored,
   bits_allocated,
   high_bit,
   pixel_mask,
   num_distinct_pixel_values,
   pixel_value,
   num_occurances
from 
  distinguished_pixel_digests natural join
  distinguished_pixel_digest_pixel_value