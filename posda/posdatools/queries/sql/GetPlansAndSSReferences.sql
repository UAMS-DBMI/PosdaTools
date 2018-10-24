-- Name: GetPlansAndSSReferences
-- Schema: posda_files
-- Columns: ['plan_referencing', 'ss_referenced']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get list of plan and ss sops where plan references ss
-- 
-- 

select sop_instance_uid as plan_referencing,
ss_referenced_from_plan as ss_referenced
from plan natural join file_plan join file_sop_common using(file_id)