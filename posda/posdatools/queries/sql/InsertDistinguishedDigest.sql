-- Name: InsertDistinguishedDigest
-- Schema: posda_files
-- Columns: []
-- Args: ['pixel_digest', 'type_of_pixel_data', 'sample_per_pixel', 'number_of_frames', 'pixel_rows', 'pixel_columns', 'bits_stored', 'bits_allocated', 'high_bit', 'pixel_mask', 'num_distinct_pixel_values']
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: insert distinguished pixel digest

insert into distinguished_pixel_digests(
  pixel_digest,
  type_of_pixel_data,
  sample_per_pixel,
  number_of_frames,
  pixel_rows,
  pixel_columns,
  bits_stored,
  bits_allocated,
  high_bit,
  pixel_mask,
  num_distinct_pixel_values) values (
  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
);