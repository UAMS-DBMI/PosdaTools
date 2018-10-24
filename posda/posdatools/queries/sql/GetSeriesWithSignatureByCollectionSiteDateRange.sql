-- Name: GetSeriesWithSignatureByCollectionSiteDateRange
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'signature', 'num_series', 'num_files']
-- Args: ['collection', 'site', 'from', 'to']
-- Tags: ['signature', 'phi_review']
-- Description: Get a list of Series with Signatures by Collection
-- 

select distinct
  series_instance_uid, dicom_file_type, 
  modality|| ':' || coalesce(manufacturer, '<undef>') || ':' 
  || coalesce(manuf_model_name, '<undef>') ||
  ':' || coalesce(software_versions, '<undef>') as signature,
  count(distinct series_instance_uid) as num_series,
  count(distinct file_id) as num_files
from
  file_series natural join file_equipment natural join ctp_file
  natural join dicom_file join file_import using(file_id)
  join import_event using(import_event_id)
where project_name = ? and site_name = ? and visibility is null
  and import_time > ? and import_time < ?
group by series_instance_uid, dicom_file_type, signature
