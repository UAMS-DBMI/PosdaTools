-- Name: GetFilePathPublicBySopInst
-- Schema: public
-- Columns: ['dicom_file_uri']
-- Args: ['sop_instance_uid']
-- Tags: ['posda_files', 'sops', 'BySopInstance']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which SOP resides
-- 

select
  dicom_file_uri
from
  general_image
where
  sop_instance_uid = ?
