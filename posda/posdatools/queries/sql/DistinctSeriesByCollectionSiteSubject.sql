-- Name: DistinctSeriesByCollectionSiteSubject
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'dicom_file_type', 'modality', 'count']
-- Args: ['project_name', 'site_name', 'patient_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select distinct patient_id, series_instance_uid, dicom_file_type, modality, count(*)
from (
select distinct patient_id, series_instance_uid, sop_instance_uid, dicom_file_type, modality from (
select
   distinct patient_id, series_instance_uid, modality, sop_instance_uid,
   file_id, dicom_file_type
 from file_series natural join file_sop_common
   natural join file_patient
   natural join ctp_file natural join dicom_file
where
  project_name = ? and site_name = ? and patient_id = ?)
as foo
group by patient_id, series_instance_uid, sop_instance_uid, dicom_file_type, modality)
as foo
group by patient_id, series_instance_uid, dicom_file_type, modality
