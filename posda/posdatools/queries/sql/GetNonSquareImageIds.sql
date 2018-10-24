-- Name: GetNonSquareImageIds
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['offset', 'limit']
-- Tags: ['ImageEdit']
-- Description: Get list of dicom_edit_event

select file_id from image natural join file_image  where pixel_rows != pixel_columns
offset ? limit ?