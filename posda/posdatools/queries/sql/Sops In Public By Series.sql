-- Name: Sops In Public By Series
-- Schema: public
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid']
-- Args: ['series_instance_uid']
-- Tags: ['Reconcile Public and Posda for CPTAC']
-- Description: Get the list of files by sop, excluding base series

select 
  tdp.project as collection, dp_site_name as site, patient_id,
  study_instance_uid, series_instance_uid, sop_instance_uid 
from
  general_image i, trial_data_provenance tdp
where
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and series_instance_uid = ?
