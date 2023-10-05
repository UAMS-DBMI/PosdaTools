-- Name: PlanToSsLinkageByCollectionSite
-- Schema: posda_files
-- Columns: ['referencing_plan', 'referenced_ss']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  sop_instance_uid as referencing_plan, ss_referenced_from_plan as referenced_ss
from
  file_plan natural join plan join file_sop_common using(file_id) natural join ctp_file
where
  project_name = ? and site_name = ?