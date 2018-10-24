-- Name: FirstFileInSeriesIntake
-- Schema: intake
-- Columns: ['path']
-- Args: ['series_instance_uid']
-- Tags: ['by_series', 'intake', 'UsedInPhiSeriesScan']
-- Description: First files in series in Intake
-- 

select
  dicom_file_uri as path
from
  general_image
where
  series_instance_uid =  ?
limit 1
