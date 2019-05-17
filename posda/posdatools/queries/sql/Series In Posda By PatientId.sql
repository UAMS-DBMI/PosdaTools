-- Name: Series In Posda By PatientId
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['patient_id']
-- Tags: ['Reconcile Public and Posda for CPTAC']
-- Description: Get the list of files by sop, excluding base series

select 
  distinct series_instance_uid
from
  file_series natural join file_patient natural join ctp_file
where 
  visibility is null and patient_id = ?

