-- Name: GetNumPixDups
-- Schema: posda_files
-- Columns: ['num_pix_dups', 'num_pix_digs']
-- Args: []
-- Tags: ['pix_data_dups', 'pixel_duplicates']
-- Description: Find series with duplicate pixel count of <n>
-- 

select distinct num_pix_dups, count(*) as num_pix_digs
from (
select
  distinct pixel_digest, count(*) as num_pix_dups
from (
   select 
       distinct unique_pixel_data_id, pixel_digest, project_name,
       site_name, patient_id, count(*) 
  from (
    select
      distinct unique_pixel_data_id, file_id, project_name,
      site_name, patient_id, 
      unique_pixel_data.digest as pixel_digest 
    from
      image join file_image using(image_id)
      join ctp_file using(file_id)
      join file_patient fq using(file_id)
      join unique_pixel_data using(unique_pixel_data_id)
    where visibility is null
  ) as foo 
  group by 
    unique_pixel_data_id, project_name, pixel_digest,
    site_name, patient_id
) as foo 
group by pixel_digest) as foo
group by num_pix_dups
order by num_pix_digs desc