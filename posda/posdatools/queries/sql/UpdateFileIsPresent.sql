-- Name: UpdateFileIsPresent
-- Schema: posda_files
-- Columns: []
-- Args: []
-- Tags: ['adding_pixels_to_dicom_file']
-- Description: Default file_is_present to true

update file_location set file_is_present = true where file_is_present is null