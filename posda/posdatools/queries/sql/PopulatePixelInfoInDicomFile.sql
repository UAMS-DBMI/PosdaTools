-- Name: PopulatePixelInfoInDicomFile
-- Schema: posda_files
-- Columns: []
-- Args: ['pixel_data_digest', 'pixel_data_offset', 'pixel_data_length', 'file_id']
-- Tags: ['adding_pixels_to_dicom_file']
-- Description: see name

update dicom_file set
  has_pixel_data = true,
  pixel_data_digest = ?,
  pixel_data_offset = ?,
  pixel_data_length = ?
where file_id = ?