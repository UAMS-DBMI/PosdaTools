-- Name: PlanSopToForByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'sop_instance_uid', 'for_uid']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  distinct patient_id,  sop_instance_uid, 
  for_uid
from 
  file_for natural join file_plan join file_sop_common using(file_id) join file_patient using (file_id)
where
  file_id in (
    select file_id 
    from ctp_file natural join file_plan 
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id