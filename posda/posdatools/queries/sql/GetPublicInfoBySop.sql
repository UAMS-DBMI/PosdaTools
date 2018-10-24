-- Name: GetPublicInfoBySop
-- Schema: public
-- Columns: ['project', 'site_name', 'site_id', 'patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['bills_test', 'comparing_posda_to_public']
-- Description: Add a filter to a tab

select 
  tdp.project, dp_site_name as site_name, dp_site_id as site_id,
  patient_id, study_instance_uid, series_instance_uid
from 
  general_image i, trial_data_provenance tdp 
where 
  tdp.trial_dp_pk_id = i.trial_dp_pk_id and sop_instance_uid = ?