-- Name: DistinctSopsInCollectionByStorageClass
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'rel_path']
-- Args: ['collection', 'storage_class']
-- Tags: ['by_collection', 'posda_files', 'sops']
-- Description: Get Distinct SOPs in Collection with number files
-- Only visible files
-- 

select distinct sop_instance_uid, rel_path
from
  file_sop_common natural join file_location natural join file_storage_root
where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_location natural join file_storage_root
  where
    project_name = ? and storage_class = ?
) and current
order by sop_instance_uid
