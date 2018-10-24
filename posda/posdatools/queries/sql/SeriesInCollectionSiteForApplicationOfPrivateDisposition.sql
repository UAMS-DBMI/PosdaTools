-- Name: SeriesInCollectionSiteForApplicationOfPrivateDisposition
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['by_collection_site', 'find_files']
-- Description: Get a patient, study, series hierarchy by collection, site

select
  distinct 
  patient_id, study_instance_uid, series_instance_uid
from
  file_patient natural join ctp_file natural join file_study 
  natural join file_sop_common natural join file_series
where
  collection = ? and site = ? and visibility is null
