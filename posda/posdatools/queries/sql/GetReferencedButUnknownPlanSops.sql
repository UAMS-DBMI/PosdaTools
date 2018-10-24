-- Name: GetReferencedButUnknownPlanSops
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'plan_sop_instance_uid']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get list of doses which reference unknown SOPs
-- 
-- 

select
  sop_instance_uid, 
  rt_dose_referenced_plan_uid as plan_sop_instance_uid 
from 
  rt_dose d natural join file_dose join file_sop_common using(file_id)
where
  not exists (
  select
    sop_instance_uid 
  from
    file_sop_common fsc
  where
    d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid
)