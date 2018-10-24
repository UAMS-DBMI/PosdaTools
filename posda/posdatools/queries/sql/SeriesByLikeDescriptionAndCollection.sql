-- Name: SeriesByLikeDescriptionAndCollection
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'series_description']
-- Args: ['collection', 'pattern']
-- Tags: ['find_series']
-- Description: Get a list of Series by Collection matching Series Description
-- 

select distinct
  series_instance_uid, series_description
from
  file_series natural join ctp_file
where project_name = ? and series_description like ?
