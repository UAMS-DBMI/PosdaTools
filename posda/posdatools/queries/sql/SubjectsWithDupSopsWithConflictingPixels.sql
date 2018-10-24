-- Name: SubjectsWithDupSopsWithConflictingPixels
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'patient_id', 'count']
-- Args: []
-- Tags: ['pix_data_dups']
-- Description: Find list of series with SOP with duplicate pixel data

select 
  distinct project_name, site_name, patient_id, count(distinct file_id)
from
  ctp_file natural join file_sop_common natural join file_patient
where sop_instance_uid in (
  select distinct sop_instance_uid
  from (
    select
      distinct sop_instance_uid, count(*)
    from (
      select
        sop_instance_uid, unique_pixel_data.digest as pixel_digest
      from
        file_sop_common natural join file natural join file_image join
        image using (image_id) join unique_pixel_data using (unique_pixel_data_id)
    )as foo group by sop_instance_uid
  ) as foo where count > 1
)
group by
  project_name, site_name, patient_id
order by 
  project_name, site_name, patient_id, count desc
  