-- Name: DistinctSeriesByCollectionModality
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'patient_id', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['collection', 'modality']
-- Tags: ['by_collection', 'find_series', 'search_series', 'send_series', 'phi_simple', 'simple_phi', 'dciodvfy', 'edit_files']
-- Description: Get Series in A Collection
-- 

select distinct series_instance_uid, patient_id, dicom_file_type, modality, count(distinct file_id) as num_files
 from file_series natural join file_sop_common
   natural join ctp_file natural join dicom_file natural join file_patient
where
  project_name = ? and modality = ?
  and visibility is null
group by series_instance_uid, patient_id, dicom_file_type, modality