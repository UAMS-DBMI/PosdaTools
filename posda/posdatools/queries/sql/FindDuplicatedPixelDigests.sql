-- Name: FindDuplicatedPixelDigests
-- Schema: posda_files
-- Columns: ['pixel_digest', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello']
-- Description: Find Duplicated Pixel Digest

select
  distinct pixel_digest, num_files
from (
  select
    distinct digest as pixel_digest, count(distinct file_id) as num_files
  from
    file_image
    join image using(image_id)
    join unique_pixel_data using (unique_pixel_data_id)
  group by digest
) as foo
where num_files > 3
order by num_files desc

