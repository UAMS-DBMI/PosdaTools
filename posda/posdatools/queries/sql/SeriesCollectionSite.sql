-- Name: SeriesCollectionSite
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['find_series']
-- Description: Get a list of Series by Collection, Site
-- 

select distinct
  series_instance_uid
from
  file_series natural join ctp_file
where project_name = ? and site_name = ?
