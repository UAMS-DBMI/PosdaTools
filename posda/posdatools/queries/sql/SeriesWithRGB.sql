-- Name: SeriesWithRGB
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: []
-- Tags: ['find_series', 'posda_files', 'rgb']
-- Description: Get distinct pixel types with geometry and rgb
-- 

select
  distinct series_instance_uid
from
  image natural join file_image
  natural join file_series
  natural join ctp_file
where
  photometric_interpretation = 'RGB'
  and visibility is null
