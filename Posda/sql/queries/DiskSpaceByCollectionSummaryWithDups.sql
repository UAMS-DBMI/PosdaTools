-- Name: DiskSpaceByCollectionSummaryWithDups
-- Schema: posda_files
-- Columns: ['collection', 'total_bytes']
-- Args: []
-- Tags: ['by_collection', 'posda_files', 'storage_used', 'summary']
-- Description: Get disk space used for all collections
-- 

select
  distinct project_name as collection, sum(size) as total_bytes
from
  ctp_file natural join file natural join file_import
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
group by project_name
order by total_bytes
