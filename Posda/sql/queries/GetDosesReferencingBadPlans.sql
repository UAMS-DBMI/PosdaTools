-- Name: GetDosesReferencingBadPlans
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  sop_instance_uid
from
  file_sop_common
where file_id in (
  select 
    file_id
  from
    rt_dose d natural join file_dose  
  where
    not exists (
      select
        sop_instance_uid 
      from
        file_sop_common fsc 
      where d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid
  )
)