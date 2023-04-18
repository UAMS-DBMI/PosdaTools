-- Name: GetFilesToEditBySopForLGCP
-- Schema: posda_files
-- Columns: ['file_id', 'path']
-- Args: ['sop_instance_uid', 'series_instance_uid']
-- Tags: ['Curation of Lung-Fused-CT-Pathology']
-- Description: Get the list of files by sop, excluding base series

select
  file_id, root_path || '/' || rel_path as path
from 
  file_sop_common natural join file_series natural join
  file_location natural join file_storage_root natural join ctp_file
where 
  sop_instance_uid = ? and series_instance_uid != ?
