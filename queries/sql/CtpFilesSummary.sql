-- Name: CtpFilesSummary
-- Schema: posda_files
-- Columns: ['collection', 'trial_name', 'site', 'site_id', 'visibility', 'num_files']
-- Args: []
-- Tags: ['adding_ctp']
-- Description: Get Series in A Collection
-- 

select
 distinct project_name as collection,
 trial_name,
 site_name as site,
 site_id,
 visibility,
 count(distinct file_id) as num_files
from ctp_file
group by 
  collection,
  trial_name,
  site,
  site_id,
  visibility
order by
  collection, trial_name, site, site_id, visibility