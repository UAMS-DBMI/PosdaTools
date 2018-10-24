-- Name: GetDoseReferencingNoPlan
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'sop_instance_uid', 'series_instance_uid', 'file_id']
-- Args: ['collection']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'dose_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from rt_dose natural join file_dose  where
rt_dose_referenced_plan_uid is null)