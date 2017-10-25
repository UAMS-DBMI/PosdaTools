-- Name: DoesDoseReferenceNoPlan
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['file_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'used_in_dose_linkage_check']
-- Description: Return a row if file references no plan
-- 
-- 

select
  file_id
from
  rt_dose  natural join file_dose
where
  rt_dose_referenced_plan_uid is null
  and file_id = ?