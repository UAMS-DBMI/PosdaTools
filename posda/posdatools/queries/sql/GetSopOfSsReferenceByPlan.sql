-- Name: GetSopOfSsReferenceByPlan
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_plan_linkage_check']
-- Description: Get Plan Reference Info for RTDOSE by file_id
-- 

select
  distinct ss_referenced_from_plan as sop_instance_uid
from
  plan natural join file_plan
where
  file_id = ?