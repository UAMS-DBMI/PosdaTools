-- Name: CountsBySeriesInstanceUidPlusNoImageType
-- Schema: posda_files
-- Columns: ['patient_id', 'study_date', 'modality', 'series_description', 'series_date', 'study_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest']
-- Args: ['SeriesInstanceUid', 'collection']
-- Tags: ['counts', 'count_queries']
-- Description: Counts query by Collection, Site
-- 

select
  distinct
    patient_id, study_date, series_instance_uid, modality,
    study_description, series_description,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file join file_patient using(file_id)
  join dicom_file using(file_id)
  join file_series using(file_id)
  join file_sop_common using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  join file_import using(file_id)
  join import_event using(import_event_id)
  left join file_image using(file_id)
  left join image using (image_id)
where
  file_id in (
    select file_id 
    from file_series
    where series_instance_uid  = ?
  ) and project_name = ? and visibility is null
group by
  patient_id, study_date, series_instance_uid, study_description, series_description, modality
order by
  patient_id, study_date, modality, series_description, series_instance_uid,
  study_description
