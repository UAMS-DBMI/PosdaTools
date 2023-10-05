-- Name: DuplicatePixelDataByProject
-- Schema: posda_files
-- Columns: ['image_id', 'file_id']
-- Args: ['collection']
-- Tags: ['pixel_duplicates']
-- Description: Return a list of files with duplicate pixel data
-- 

select image_id, file_id
from file_image where image_id in (
  select image_id
  from (
    select distinct image_id, count(*)
    from (
      select distinct image_id, file_id 
      from file_image
      where file_id in (
        select
          distinct file_id 
        from ctp_file
        where project_name = ?
      )
    ) as foo
    group by image_id
  ) as foo
  where count > 1
)
order by image_id;
