-- Name: DistinctSeriesByCollectionSite
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'dicom_file_type', 'modality', 'count']
-- Args: ['project_name', 'site_name']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select distinct series_instance_uid, dicom_file_type, modality, count(*)
from (
select distinct series_instance_uid, sop_instance_uid, dicom_file_type, modality from (
select
   distinct series_instance_uid, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file
where
  project_name = ? and site_name = ?
  and visibility is null)
as foo
group by series_instance_uid, sop_instance_uid, dicom_file_type, modality)
as foo
group by series_instance_uid, dicom_file_type, modality
