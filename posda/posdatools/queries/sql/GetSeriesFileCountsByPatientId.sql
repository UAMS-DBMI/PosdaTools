-- Name: GetSeriesFileCountsByPatientId
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'modality', 'dicom_file_type', 'num_sops']
-- Args: ['patient_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get Counts in file_series by patient_id
-- 
-- 

select
  series_instance_uid, modality, dicom_file_type, count(distinct sop_instance_uid) as num_sops
from
  file_series natural join file_patient natural join 
  dicom_file natural join file_sop_common
where
  patient_id = ?
group by series_instance_uid, modality, dicom_file_type
