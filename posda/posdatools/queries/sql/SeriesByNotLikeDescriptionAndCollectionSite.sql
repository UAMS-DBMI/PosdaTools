-- Name: SeriesByNotLikeDescriptionAndCollectionSite
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'series_description']
-- Args: ['collection', 'site', 'pattern']
-- Tags: ['find_series']
-- Description: Get a list of Series by Collection, Site not matching Series Description
-- 

select distinct
  series_instance_uid, series_description
from
  file_series natural join ctp_file
where 
  project_name = ? and site_name = ? and 
  series_description not like ?
