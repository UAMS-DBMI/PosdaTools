-- Name: SopFilePathByTimepoint
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'file_id', 'file_path']
-- Args: ['activity_timepoint_id']
-- Tags: ['compare_timepoints']
-- Description: get sop_instance, file_id, and file_path for all files in timepoint
-- 

select
  sop_instance_uid, file_id, root_path || '/' || rel_path as file_path
from
  file_sop_common natural join file_location natural join file_storage_root
where file_id in (
  select file_id from activity_timepoint_file
  where activity_timepoint_id = ?
)