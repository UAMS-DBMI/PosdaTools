-- Name: ListOfCollectionsAndSitesLikeCollection
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'count']
-- Args: ['CollectionLike']
-- Tags: ['AllCollections', 'universal']
-- Description: Get a list of collections and sites
-- 

select 
    distinct project_name, site_name, count(*) 
from 
   ctp_file natural join file_study natural join
   file_series
where
  project_name like ?
group by project_name, site_name
order by project_name, site_name
