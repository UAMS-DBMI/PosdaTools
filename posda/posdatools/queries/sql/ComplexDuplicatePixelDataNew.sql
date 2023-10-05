-- Name: ComplexDuplicatePixelDataNew
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient', 'series_instance_uid', 'num_files']
-- Args: ['num_pix_dups']
-- Tags: ['pix_data_dups', 'pixel_duplicates']
-- Description: Find series with duplicate pixel count of <n>
-- 

select distinct project_name as collection,
site_name as site,
patient_id as patient,
series_instance_uid, count(distinct file_id) as num_files
from
ctp_file natural join file_patient
natural join file_series where file_id in (
select file_id from 
file_image join image using(image_id) 
join unique_pixel_data using (unique_pixel_data_id)
where digest in (
select distinct pixel_digest as digest from (
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
  ) as foo 
  group by 
    unique_pixel_data_id, project_name, pixel_digest,
    site_name, patient_id
) as foo 
group by pixel_digest) as foo
where num_pix_dups = ?))
group by collection, site, patient, series_instance_uid
order by num_files desc