-- Name: DistinctSeriesByImportEvent
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'patient_name', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'count']
-- Args: ['import_event_id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_selection', 'activity_timepoints']
-- Description: Get Series in A Collection, site with dicom_file_type, modality, and sop_count
-- 

select
  distinct project_name as collection, site_name as site, 
  patient_id, patient_name, study_instance_uid, series_instance_uid, 
  dicom_file_type, modality, count(distinct file_id)
from
  file_patient natural join file_study natural join file_series natural join dicom_file
  natural left join ctp_file
where
  file_id in (
    select distinct file_id from file_import where import_event_id = ?
  )
group by collection, site, patient_id, patient_name,
  study_instance_uid, series_instance_uid, dicom_file_type, modality