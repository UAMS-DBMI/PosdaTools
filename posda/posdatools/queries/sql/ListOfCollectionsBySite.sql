-- Name: ListOfCollectionsBySite
-- Schema: posda_files
-- Columns: ['collection', 'site_name', 'count']
-- Args: ['site']
-- Tags: ['AllCollections', 'universal']
-- Description: Get a list of collections and sites
-- 

select 
    distinct project_name as collection, site_name, count(*) 
from 
   ctp_file natural join file_study natural join
   file_series
where
  site_name = ?
group by project_name, site_name
order by project_name, site_name
