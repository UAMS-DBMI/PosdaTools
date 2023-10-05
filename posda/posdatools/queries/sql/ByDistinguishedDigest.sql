-- Name: ByDistinguishedDigest
-- Schema: posda_files
-- Columns: ['collection', 'site', 'subject', 'series_instance_uid', 'num_sops']
-- Args: ['pixel_digest']
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id as subject,
  series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join
  file_patient natural join
  file_sop_common natural join
  file_series
where file_id in (
  select 
    file_id
  from
    file_image
    join image using(image_id)
    join unique_pixel_data using(unique_pixel_data_id)
  where digest = ?
  )
group by 
  collection,
  site,
  series_instance_uid,
  subject
order by
  collection,
  site,
  subject