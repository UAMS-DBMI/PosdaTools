-- Name: SsRoiForsBySopInstance
-- Schema: posda_files
-- Columns: ['for_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  distinct for_uid
from
  roi natural join file_structure_set
where
  file_id in (
    select file_id 
    from file_sop_common natural join ctp_file
    where sop_instance_uid = ?
  )