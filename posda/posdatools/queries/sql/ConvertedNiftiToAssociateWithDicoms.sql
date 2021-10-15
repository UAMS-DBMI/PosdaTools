-- Name: ConvertedNiftiToAssociateWithDicoms
-- Schema: posda_files
-- Columns: ['activity_timepoint_id', 'nifti_file_id', 'series_instance_uid']
-- Args: []
-- Tags: ['nifti']
-- Description: Get Nifti Conversions For Association with Dicom Files in Series
-- 

select 
  activity_timepoint_id,  nifti_file_id, series_instance_uid 
from
  nifti_file_from_series join dicom_to_nifti_conversion using (dicom_to_nifti_conversion_id)
where
  nifti_file_id is not null and
  mapped_to_dicom_files is null