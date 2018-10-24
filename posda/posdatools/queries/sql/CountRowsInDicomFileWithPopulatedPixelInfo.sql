-- Name: CountRowsInDicomFileWithPopulatedPixelInfo
-- Schema: posda_files
-- Columns: ['count']
-- Args: []
-- Tags: ['adding_pixels_to_dicom_file']
-- Description: count rows in dicom_file with unpopulated pixel info

select 
 count(*) from dicom_file where has_pixel_data is not null