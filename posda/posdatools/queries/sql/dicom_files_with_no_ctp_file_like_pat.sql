-- Name: dicom_files_with_no_ctp_file_like_pat
-- Schema: posda_files
-- Columns: ['patient_id', 'dicom_file_type', 'modality', 'num_files', 'earliest', 'latest']
-- Args: ['patient_id_pattern']
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select 
  distinct patient_id,
  dicom_file_type, 
  modality, 
  count(distinct file_id) as num_files, 
  min(import_time) as earliest, 
  max(import_time) as latest 
from
  dicom_file d natural join
  file_patient natural join 
  file_series natural join
  file_import natural join
  import_event
where not exists (select file_id from ctp_file c where c.file_id = d.file_id) and patient_id like ?
group by patient_id, dicom_file_type, modality