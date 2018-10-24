-- Name: dicom_files_with_no_ctp_file
-- Schema: posda_files
-- Columns: ['patient_id', 'dicom_file_type', 'modality', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'query_tabs', 'bills_test']
-- Description: Add a filter to a tab

select distinct patient_id, dicom_file_type, modality, count(distinct file_id) as num_files
from dicom_file d natural join file_patient natural join file_series
where not exists (select file_id from ctp_file c where c.file_id = d.file_id) 
group by patient_id, dicom_file_type, modality