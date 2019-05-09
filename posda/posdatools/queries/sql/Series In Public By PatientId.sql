-- Name: Series In Public By PatientId
-- Schema: public
-- Columns: ['series_instance_uid']
-- Args: ['patient_id']
-- Tags: ['Reconcile Public and Posda for CPTAC']
-- Description: Get the list of files by sop, excluding base series

select 
  distinct series_instance_uid
from
  general_image i, trial_data_provenance tdp
where
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and patient_id = ?
