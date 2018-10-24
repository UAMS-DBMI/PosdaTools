-- Name: GetSeriesWithImageByCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'modality', 'series_instance_uid', 'num_sops', 'num_files']
-- Args: ['collection']
-- Tags: ['signature', 'phi_review', 'visual_review']
-- Description: Get a list of Series with images by CollectionSite
-- 

select distinct
  project_name as collection, site_name as site,
  patient_id, modality, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series natural join file_sop_common
  natural join file_patient
  natural join file_image natural join ctp_file
  natural join file_import natural join import_event
where project_name = ? and visibility is null
group by
  collection, site, patient_id, modality, series_instance_uid
