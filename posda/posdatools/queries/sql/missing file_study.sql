-- Name: missing file_study
-- Schema: posda_files
-- Columns: ['patient_id', 'dicom_file_type', 'series_instance_uid', 'modality', 'num_files', 'earliest', 'latest']
-- Args: ['collection', 'site']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select distinct patient_id, dicom_file_type, series_instance_uid, modality, count(distinct file_id) as num_files,
  min(import_time) as earliest, max(import_time) as latest
from 
file_patient natural join dicom_file natural join file_series
natural join file_import natural join import_event
where file_id in (
select file_id from 
ctp_file where project_name =? and site_name = ? and visibility is null and not exists (select file_id from file_study where file_study.file_id = ctp_file.file_id)) group by patient_id, dicom_file_type, series_instance_uid, modality