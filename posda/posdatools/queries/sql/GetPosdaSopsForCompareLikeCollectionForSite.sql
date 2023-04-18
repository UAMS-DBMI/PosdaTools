-- Name: GetPosdaSopsForCompareLikeCollectionForSite
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_type', 'file_path', 'file_id']
-- Args: ['collection', 'site']
-- Tags: ['public_posda_counts']
-- Description: Generate a long list of all unhidden SOPs for a collection in posda<br>
-- <em>This can generate a long list</em>

select
  distinct patient_id,
  study_instance_uid, 
  series_instance_uid, 
  sop_instance_uid,
  sop_class_uid,
  modality,
  dicom_file_type,
  root_path || '/' || rel_path as file_path,
  file_id
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  project_name like ? and site_name = ?