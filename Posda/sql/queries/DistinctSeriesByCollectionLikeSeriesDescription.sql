-- Name: DistinctSeriesByCollectionLikeSeriesDescription
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'series_description', 'dicom_file_type', 'modality', 'num_sops', 'num_files']
-- Args: ['collection', 'site', 'description']
-- Tags: ['by_collection', 'find_series']
-- Description: Get Series in A Collection
-- 

select 
  distinct collection, 
  site, patient_id, series_instance_uid, 
  series_description,
  dicom_file_type, modality, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
  from (
    select
     distinct project_name as collection,
     site_name as site,
     patient_id, 
     series_instance_uid, 
     series_description,
     dicom_file_type, 
     modality, sop_instance_uid,
     file_id
    from 
     file_series
     natural join dicom_file
     natural join file_sop_common 
     natural join file_patient
     natural join ctp_file
  where
    project_name = ? 
    and site_name = ? 
    and series_description like ?
    and visibility is null
) as foo
group by collection, site, patient_id, 
  series_instance_uid, series_description, dicom_file_type, modality
