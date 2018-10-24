-- Name: StructVolByFileId
-- Schema: posda_files
-- Columns: ['sop_instance', 'sop_class', 'study_instance_uid', 'series_instance_uid', 'for_uid']
-- Args: ['file_id']
-- Tags: ['LinkageChecks', 'used_in_struct_linkage_check']
-- Description: Get list of Roi with info by file_id
-- 
-- 

select
  distinct sop_instance,
  sop_class,
  study_instance_uid,
  series_instance_uid,
  for_uid
from
  file_structure_set natural join
  ss_for natural join
  ss_volume
where file_id = ?