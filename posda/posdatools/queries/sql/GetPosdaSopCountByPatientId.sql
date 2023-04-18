-- Name: GetPosdaSopCountByPatientId
-- Schema: posda_files
-- Columns: ['patient_id', 'num_sops']
-- Args: ['patient_id']
-- Tags: ['public_posda_counts']
-- Description: Generate a long list of all unhidden SOPs for a collection in posda<br>
-- <em>This can generate a long list</em>

select
  distinct patient_id,
  count(distinct sop_instance_uid) as num_sops
from
  ctp_file
  natural join dicom_file
  natural join file_patient
  natural join file_study
  natural join file_series
  natural join file_sop_common
  natural join file_location
  natural join file_storage_root
where
  patient_id = ? 
group by patient_id