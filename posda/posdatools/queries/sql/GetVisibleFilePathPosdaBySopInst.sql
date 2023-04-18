-- Name: GetVisibleFilePathPosdaBySopInst
-- Schema: posda_files
-- Columns: ['path']
-- Args: ['sop_instance_uid']
-- Tags: ['posda_files', 'sops', 'BySopInstance']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which SOP resides
-- 

select
  root_path || '/' || rel_path as path
from
  file_location natural join file_storage_root
where
  file_id in (
    select file_id from file_sop_common natural join ctp_file
    where sop_instance_uid = ?
)