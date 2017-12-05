-- Name: SimpleCountQuery
-- Schema: posda_files
-- Columns: ['patient_id', 'dicom_file_type', 'modality', 'study_instance_uid', 'series_instance_uid', 'num_sops', 'num_files']
-- Args: ['collection', 'site']
-- Tags: ['counts', 'count_queries']
-- Description: Counts query by Collection, Site
-- 

select
  distinct
    patient_id, dicom_file_type, modality,
    study_instance_uid, series_instance_uid,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
where
  project_name = ?  and site_name = ? and visibility is null
group by
  patient_id, dicom_file_type, modality,
  study_instance_uid, series_instance_uid
order by
  patient_id, study_instance_uid, series_instance_uid,
  modality
