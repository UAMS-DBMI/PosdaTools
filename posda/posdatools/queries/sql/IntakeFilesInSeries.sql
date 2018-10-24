-- Name: IntakeFilesInSeries
-- Schema: intake
-- Columns: ['file_path']
-- Args: ['series_instance_uid']
-- Tags: ['intake', 'used_in_simple_phi']
-- Description: List of all Series By Collection, Site on Intake
-- 

select
  dicom_file_uri as file_path
from
  general_image
where
  series_instance_uid = ?
