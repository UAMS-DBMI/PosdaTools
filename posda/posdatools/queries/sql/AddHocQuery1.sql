-- Name: AddHocQuery1
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'dicom_file_type', 'modality', 'num_files', 'num_sops', 'earliest', 'latest']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'bills_test']
-- Description: Add a filter to a tab

select 
  distinct project_name as collection, site_name as site, patient_id,
  study_instance_uid, series_instance_uid, dicom_file_type, modality,
  count(distinct file_id) as num_files, count(distinct sop_instance_uid) as num_sops,
  min(import_time) as earliest, max(import_time) as latest
from
  ctp_file natural join file_patient natural join dicom_file natural join file_series natural join
  file_sop_common natural join
  file_study join file_import using(file_id) join import_event using (import_event_id)
where file_id in(
  select distinct file_id from file_patient where patient_id = 'ER-1125'
) and visibility is null 
group by collection, site, patient_id, study_instance_uid, series_instance_uid, dicom_file_type, modality