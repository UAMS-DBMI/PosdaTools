-- Name: DistinctSeriesByCollectionSiteBatch
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'count']
-- Args: ['project_name', 'site_name', 'batch']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select distinct series_instance_uid, dicom_file_type, modality, count(distinct file_id)
from
  file_study natural join file_series natural join dicom_file natural join ctp_file
where
  project_name = ? and site_name = ? and batch = ? and visibility is null
group by series_instance_uid, dicom_file_type, modality
