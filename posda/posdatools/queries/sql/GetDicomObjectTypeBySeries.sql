-- Name: GetDicomObjectTypeBySeries
-- Schema: posda_files
-- Columns: ['dicom_object_type']
-- Args: ['series_instance_uid']
-- Tags: ['populate_posda_files', 'bills_test']
-- Description: Gets count of all files which are PET's which haven't been imported into file_pt_image yet.
-- 
-- 

select 
  distinct 
  dicom_file_type as dicom_object_type
from dicom_file natural join file_series natural join ctp_file 
where series_instance_uid = ? and visibility is null
