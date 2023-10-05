-- Name: GetDoseReferencingGoodPlan
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id']
-- Args: ['collection']
-- Tags: ['LinkageChecks', 'dose_linkages']
-- Description: Get list of plan which reference known SOPs
-- 
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  file_id in (
select file_id from rt_dose d  natural join file_dose  where
exists (select sop_instance_uid from file_sop_common fsc where d.rt_dose_referenced_plan_uid
= fsc.sop_instance_uid))