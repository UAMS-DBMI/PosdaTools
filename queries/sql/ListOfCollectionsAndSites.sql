-- Name: ListOfCollectionsAndSites
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'count']
-- Args: []
-- Tags: ['AllCollections', 'universal']
-- Description: Get a list of collections and sites
-- 

select 
    distinct project_name, site_name, count(*) 
from 
   ctp_file natural join file_study natural join
   file_series
where
  visibility is null
group by project_name, site_name
order by project_name, site_name
