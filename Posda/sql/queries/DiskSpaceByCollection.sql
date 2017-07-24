-- Name: DiskSpaceByCollection
-- Schema: posda_files
-- Columns: ['collection', 'total_bytes']
-- Args: ['collection']
-- Tags: ['by_collection', 'posda_files', 'storage_used']
-- Description: Get disk space used by collection
-- 

select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  where project_name = ?
  )
group by project_name
