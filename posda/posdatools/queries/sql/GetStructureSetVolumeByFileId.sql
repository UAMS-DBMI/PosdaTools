-- Name: GetStructureSetVolumeByFileId
-- Schema: posda_files
-- Columns: ['sop_instance']
-- Args: ['file_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of SOP's linked in SS
-- 
-- 

select
  distinct sop_instance
from
  ss_volume natural join ss_for natural join file_structure_set
where file_id = ?