-- Name: DicomSliceNiftiSliceRowCountByNiftiFileId
-- Schema: posda_files
-- Columns: ['row_count']
-- Args: ['nifti_file_id']
-- Tags: ['nifti']
-- Description: Get the number of nifti_slices which have been associated with a dicom slice for a given nifti file
-- 

select
  count(*) as row_count
from
  dicom_slice_nifti_slice
where
  nifti_file_id = ?