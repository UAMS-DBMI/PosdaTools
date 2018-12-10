-- Name: FindDuplicatedPixelDigestsNew
-- Schema: posda_files
-- Columns: ['pixel_digest', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello']
-- Description: Find Duplicated Pixel Digest

select
  distinct pixel_digest, num_files
from (
  select
    distinct pixel_data_digest as pixel_digest, count(distinct file_id) as num_files
  from
    dicom_file
  where 
    has_pixel_data
    group by pixel_data_digest
) as foo 
where num_files > 3
order by num_files desc