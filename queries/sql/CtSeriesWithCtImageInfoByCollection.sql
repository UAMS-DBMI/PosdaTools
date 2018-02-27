-- Name: CtSeriesWithCtImageInfoByCollection
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'num_files']
-- Args: ['collection']
-- Tags: ['populate_posda_files', 'bills_test', 'ct_image_consistency']
-- Description: Get CT Series with CT Image Info by collection
-- 
-- 

select
  distinct series_instance_uid, count(distinct file_id) as num_files
from file_series natural join file_ct_image natural join ctp_file
where kvp is not null and visibility is null and project_name = ? group by series_instance_uid