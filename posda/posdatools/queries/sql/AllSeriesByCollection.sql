-- Name: AllSeriesByCollection
-- Schema: posda_files
-- Columns: ['patient_id', 'image_type', 'modality', 'study_date', 'study_description', 'series_description', 'study_instance_uid', 'series_instance_uid', 'manufacturer', 'manuf_model_name', 'software_versions', 'num_sops', 'num_files', 'first_loaded', 'last_loaded']
-- Args: ['collection']
-- Tags: ['counts']
-- Description: Counts query by Collection
-- 

select
  distinct
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid,
    manufacturer, manuf_model_name, software_versions,
    count(distinct sop_instance_uid) as num_sops,
    count(distinct file_id) as num_files,
    min(file_import_time) as first_loaded,
    max(file_import_time) as last_loaded
from (
    select 
      patient_id, image_type, modality, study_date, study_description,
      series_description, study_instance_uid, series_instance_uid,
      manufacturer, manuf_model_name, software_versions,
      sop_instance_uid, file_id, 
      coalesce(file_import_time, import_time) as file_import_time
  from
    file_patient join ctp_file using(file_id)
    join file_series using(file_id)
    join file_sop_common using(file_id)
    join file_study using(file_id)
    join file_equipment using(file_id)
    left join file_image using(file_id)
    left join image using (image_id)
    join file_import using (file_id)
    join import_event using (import_event_id)
  where
    project_name = ?
) as foo
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid,
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type,
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
