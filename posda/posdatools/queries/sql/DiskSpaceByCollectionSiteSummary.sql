-- Name: DiskSpaceByCollectionSiteSummary
-- Schema: posda_files
-- Columns: ['collection', 'site', 'total_bytes']
-- Args: []
-- Tags: ['by_collection', 'posda_files', 'storage_used', 'summary']
-- Description: Get disk space used for all collections, sites
-- 

select
  distinct project_name as collection, site_name as site, sum(size) as total_bytes
from
  ctp_file natural join file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
group by project_name, site_name
order by total_bytes
