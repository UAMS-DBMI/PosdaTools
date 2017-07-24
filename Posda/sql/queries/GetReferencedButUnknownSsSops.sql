-- Name: GetReferencedButUnknownSsSops
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'ss_sop_instance_uid']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  sop_instance_uid, 
  ss_referenced_from_plan as ss_sop_instance_uid 
from 
  plan p natural join file_plan join file_sop_common using(file_id)
where
  not exists (
  select
    sop_instance_uid 
  from
    file_sop_common fsc
  where
    p.ss_referenced_from_plan  = fsc.sop_instance_uid
)