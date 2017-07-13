-- Name: GetSeriesWithOutImageByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['signature', 'phi_review', 'visual_review']
-- Description: Get a list of Series with images by CollectionSite
-- 

select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series
  natural join file_sop_common
  natural join file_patient
  natural join ctp_file ctp
  natural join file_import natural join import_event
where project_name = ? and site_name = ? and visibility is null
  and not exists (select image_id from file_image fi where ctp.file_id = fi.file_id)
group by
  collection, site, patient_id, modality, series_instance_uid
