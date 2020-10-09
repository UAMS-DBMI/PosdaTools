-- Name: StructVolByFileIdWithMoreInfo
-- Schema: posda_files
-- Columns: ['file_id', 'visibility', 'sop_instance_uid']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 

select
  distinct file_id, visibility,  sop_instance_uid
from
  file_sop_common natural join ctp_file
where sop_instance_uid in (
  select
    distinct sop_instance
  from
    file_structure_set natural join
    ss_for natural join
    ss_volume
  where file_id = ?
)