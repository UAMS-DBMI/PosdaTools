-- Name: SeriesNotLikeWithModality
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'series_description', 'count']
-- Args: ['modality', 'collection', 'site', 'description_not_matching']
-- Tags: ['find_series', 'pattern', 'posda_files']
-- Description: Select series not matching pattern by modality
-- 

select
   distinct series_instance_uid, series_description, count(*)
from (
  select
   distinct
     file_id, series_instance_uid, series_description
  from
     ctp_file natural join file_series
  where
     modality = ? and project_name = ? and site_name = ? and 
     series_description not like ? and visibility is null
) as foo
group by series_instance_uid, series_description
