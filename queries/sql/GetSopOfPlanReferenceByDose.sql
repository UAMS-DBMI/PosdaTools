-- Name: GetSopOfPlanReferenceByDose
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'sop_class_uid']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_dose_linkage_check']
-- Description: Get Plan Reference Info for RTDOSE by file_id
-- 

select
  distinct rt_dose_referenced_plan_uid as sop_instance_uid,
  rt_dose_referenced_plan_class as sop_class_uid
from
  rt_dose natural join file_dose
where
  file_id = ?