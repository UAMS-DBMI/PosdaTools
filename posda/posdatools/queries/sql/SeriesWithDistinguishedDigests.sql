-- Name: SeriesWithDistinguishedDigests
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'num_sops']
-- Args: []
-- Tags: ['duplicates', 'distinguished_digest']
-- Description: show series with distinguished digests and counts

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  count(distinct sop_instance_uid) as num_sops
from
  ctp_file natural join
  file_patient natural
  join file_series natural
  join file_sop_common
where file_id in(
  select file_id 
  from
    file_image
    join image using (image_id)
    join unique_pixel_data using (unique_pixel_data_id)
  where digest in (
    select distinct pixel_digest as digest 
    from distinguished_pixel_digests
  )
) group by collection, site, patient_id, series_instance_uid