-- Name: ListOfCollectionsAndSites
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'count']
-- Args: []
-- Tags: ['AllCollections', 'universal']
-- Description: Get a list of collections and sites
-- 
-- optimized by Quasar on 2018-08-08

select
    project_name,
	site_name,
	count(*) 
from 
	ctp_file 
where
  visibility is null

group by project_name, site_name
order by project_name, site_name
