-- Name: FindPotentialDistinguishedSops
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'image_id', 'count']
-- Args: []
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select 
  distinct project_name as collection,
  site_name as site, 
  patient_id, 
  image_id,
  count(*)
from
  ctp_file
  natural join file_patient
  natural join file_image
where
  file_id in 
  (select 
    distinct file_id 
  from
    file_image 
  where
    image_id in
    (select
       image_id from 
       (select
         distinct image_id, count(distinct file_id) 
       from
         file_image 
       group by image_id
       ) as foo
     where count > 1000
  )
) group by collection, site, patient_id, image_id
order by collection, site, image_id, patient_id

