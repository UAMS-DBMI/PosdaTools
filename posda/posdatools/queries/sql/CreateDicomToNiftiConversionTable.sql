-- Name: CreateDicomToNiftiConversionTable
-- Schema: posda_files
-- Columns: []
-- Args: ['subprocess_invocation_id', 'activity_timepoint_id']
-- Tags: ['nifti']
-- Description: Create row in dicom_to_nifti_conversion table 
-- 

insert into dicom_to_nifti_conversion(
  subprocess_invocation_id,
  activity_timepoint_id
) values (
   ?, ?
)
returning dicom_to_nifti_conversion_id
