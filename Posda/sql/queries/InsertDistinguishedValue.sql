-- Name: InsertDistinguishedValue
-- Schema: posda_files
-- Columns: []
-- Args: ['pixel_digest', 'value', 'num_occurances']
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: insert distinguished pixel digest

insert into distinguished_pixel_digest_pixel_value(
  pixel_digest, pixel_value, num_occurances
  ) values (
  ?, ?, ?
)