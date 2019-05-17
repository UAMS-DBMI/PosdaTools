-- Name: PublicFileBySopInstanceUid
-- Schema: public
-- Columns: ['file_path']
-- Args: ['sop_instance_uid']
-- Tags: ['public', 'used_in_simple_phi']
-- Description: List of all Series By Collection, Site on Intake
-- 

select
  dicom_file_uri as file_path
from
  general_image
where
  sop_instance_uid = ?
