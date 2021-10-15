-- Name: InsertDicomSliceNiftiSlice
-- Schema: posda_files
-- Columns: []
-- Args: ['dicom_file_id', 'nifti_file_id', 'nifti_slice_number', 'pixel_data_digest']
-- Tags: ['nifti']
-- Description: Insert a row in dicom_slice_nifti_slice
-- 

insert into dicom_slice_nifti_slice(
  dicom_file_id, nifti_file_id, nifti_slice_number, pixel_data_digest, nifti_volume_number
) values(
  ?, ?, ?, ?, 0
)