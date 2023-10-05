-- Name: CountsCollectionDateRangeBySubject
-- Schema: posda_files
-- Columns: ['patient_id', 'num_sops', 'num_files', 'earliest', 'latest']
-- Args: ['from', 'to', 'collection']
-- Tags: ['counts', 'count_queries']
-- Description: Counts query by Collection, Site
-- 

select
  distinct
    patient_id,
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
    from file_import natural join import_event
    where import_time > ? and import_time < ?
  ) and project_name = ?
group by
  patient_id
order by
  patient_id
