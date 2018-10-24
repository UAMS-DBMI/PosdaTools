-- Name: GetPublicSopsForCompareCollectionLike
-- Schema: public
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'sop_class_uid', 'modality', 'dicom_file_uri']
-- Args: ['collection']
-- Tags: ['public_posda_counts']
-- Description: Generate a long list of all unhidden SOPs for a collection in public<br>
-- <em>This can generate a long list</em>

select
  i.patient_id,
  i.study_instance_uid,
  s.series_instance_uid,
  sop_instance_uid,
  sop_class_uid,
  s.modality,
  i.dicom_file_uri
from
  general_image i,
  trial_data_provenance tdp,
  general_series s
where  
  i.trial_dp_pk_id = tdp.trial_dp_pk_id 
  and tdp.project like ?
  and i.general_series_pk_id = s.general_series_pk_id