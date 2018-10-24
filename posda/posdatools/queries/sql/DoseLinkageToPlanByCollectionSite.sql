-- Name: DoseLinkageToPlanByCollectionSite
-- Schema: posda_files
-- Columns: ['referencing_dose', 'referenced_plan']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages', 'dose_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  sop_instance_uid as referencing_dose,
  rt_dose_referenced_plan_uid as referenced_plan
from
  rt_dose natural join file_dose natural join file_sop_common natural join ctp_file
where
  project_name = ? and site_name = ? and visibility is null