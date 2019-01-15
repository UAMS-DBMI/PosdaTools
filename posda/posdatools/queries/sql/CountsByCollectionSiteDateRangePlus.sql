-- Name: CountsByCollectionSiteDateRangePlus
-- Schema: posda_files
-- Columns: ['patient_id', 'image_type', 'dicom_file_type', 'modality', 'study_date', 'series_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'earliest', 'latest']
-- Args: ['collection', 'site', 'from', 'to']
-- Tags: ['counts', 'count_queries']
-- Description: Counts query by Collection, Site
-- 

select
  distinct
    patient_id, image_type, dicom_file_type, modality,
    study_date, series_date,
    study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct ctp_file.file_id) as num_files,
    min(import_time) as earliest,
    max(import_time) as latest
from
  ctp_file inner join file_patient on ctp_file.file_id = file_patient.file_id and project_name = ? and site_name = ? and visibility is null
    inner join file_import on ctp_file.file_id = file_import.file_id
    inner join import_event on import_event.import_event_id = file_import.import_event_id and import_time > ? and import_time < ?
    inner join dicom_file on ctp_file.file_id = dicom_file.file_id
    inner join file_series on ctp_file.file_id = file_series.file_id
    inner join file_sop_common on ctp_file.file_id = file_sop_common.file_id
    inner join file_study on ctp_file.file_id = file_study.file_id
    inner join file_equipment on ctp_file.file_id = file_equipment.file_id
    left join file_image on ctp_file.file_id = file_image.file_id
    left join image using (image_id)
group by
  patient_id, image_type, dicom_file_type, modality, study_date, 
  series_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, series_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
