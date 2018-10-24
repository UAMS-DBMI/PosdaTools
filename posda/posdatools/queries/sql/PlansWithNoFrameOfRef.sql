-- Name: PlansWithNoFrameOfRef
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  file_id,
  root_path || '/' || rel_path as path
from
  file_location natural join file_storage_root natural join ctp_file
where 
  file_id in (
    select file_id 
    from file_plan p
    where not exists (select for_uid from file_for f where f.file_id = p.file_id)
  )