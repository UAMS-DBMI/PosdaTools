-- Name: GetDoseReferencingBadPlan
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id']
-- Args: ['collection']
-- Tags: ['LinkageChecks', 'dose_linkages']
-- Description: Get list of RTDOSE which reference unknown SOPs
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
  visibility is null and
  file_id in (
select file_id from rt_dose d natural join file_dose  where
not exists (select sop_instance_uid from file_sop_common fsc where d.rt_dose_referenced_plan_uid
= fsc.sop_instance_uid))