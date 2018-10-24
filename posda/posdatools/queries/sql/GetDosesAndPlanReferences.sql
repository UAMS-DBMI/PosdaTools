-- Name: GetDosesAndPlanReferences
-- Schema: posda_files
-- Columns: ['dose_referencing', 'plan_referenced']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get list of dose and plan sops where dose references plan
-- 

select
  sop_instance_uid as dose_referencing,
  rt_dose_referenced_plan_uid as plan_referenced
from
  rt_dose natural join file_dose join file_sop_common using (file_id)