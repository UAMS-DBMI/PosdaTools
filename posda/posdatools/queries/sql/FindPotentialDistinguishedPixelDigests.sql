-- Name: FindPotentialDistinguishedPixelDigests
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'pixel_digest', 'pixel_rows', 'pixel_columns', 'bits_allocated', 'count']
-- Args: []
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select 
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  modality,
  dicom_file_type,
  digest as pixel_digest,
  pixel_rows,
  pixel_columns,
  bits_allocated,
  count(*)
from
  ctp_file
  natural join file_patient
  natural join file_series
  natural join file_image
  natural join dicom_file
  join image using (image_id)
  join unique_pixel_data using(unique_pixel_data_id)
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
     where count > 10
  )
) 
group by collection, site, patient_id, series_instance_uid,
modality, dicom_file_type,
digest, pixel_rows, pixel_columns, bits_allocated
order by digest, collection, site, patient_id

