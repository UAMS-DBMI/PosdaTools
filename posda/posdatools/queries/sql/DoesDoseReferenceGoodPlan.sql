-- Name: DoesDoseReferenceGoodPlan
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_dose_linkage_check']
-- Description: Determine whether an RTDOSE references a known plan
-- 
-- 

select
  sop_instance_uid
from
  file_sop_common fsc, rt_dose d natural join file_dose f
where
  f.file_id = ? and d.rt_dose_referenced_plan_uid = fsc.sop_instance_uid