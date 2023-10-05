-- Name: ComplexDuplicatePixelData
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'patient_id', 'series_instance_uid', 'count']
-- Args: ['count']
-- Tags: ['pix_data_dups', 'pixel_duplicates']
-- Description: Find series with duplicate pixel count of <n>
-- 

select 
  distinct project_name, site_name, patient_id, series_instance_uid, count(*)
from 
  ctp_file natural join file_patient natural join file_series 
where 
  file_id in (
    select 
      distinct file_id
    from
      file_image natural join image natural join unique_pixel_data
      natural join ctp_file
    where digest in (
      select
        distinct pixel_digest
      from (
        select
          distinct pixel_digest, count(*)
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
              image natural join file_image natural join 
              ctp_file natural join file_patient fq
              join unique_pixel_data using(unique_pixel_data_id)
          ) as foo 
          group by 
            unique_pixel_data_id, project_name, pixel_digest,
            site_name, patient_id
        ) as foo 
        group by pixel_digest
      ) as foo 
      where count = ?
    )
  ) 
group by project_name, site_name, patient_id, series_instance_uid
order by count desc;
