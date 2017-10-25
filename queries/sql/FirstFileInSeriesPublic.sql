-- Name: FirstFileInSeriesPublic
-- Schema: public
-- Columns: ['path']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'UsedInPhiSeriesScan', 'public']
-- Description: First files in series in Public
-- 

select
  dicom_file_uri as path
from
  general_image
where
  series_instance_uid =  ?
limit 1
