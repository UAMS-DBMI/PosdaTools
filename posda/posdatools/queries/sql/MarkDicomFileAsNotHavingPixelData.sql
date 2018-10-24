-- Name: MarkDicomFileAsNotHavingPixelData
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id']
-- Tags: ['adding_pixels_to_dicom_file']
-- Description: see name

update dicom_file set has_pixel_data = false where file_id = ?