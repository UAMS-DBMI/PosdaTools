-- Name: InputImagesByImageEquivalenceClass
-- Schema: posda_files
-- Columns: ['file_id', 'pixel_rows', 'pixel_columns']
-- Args: ['image_equivalence_class_id']
-- Tags: ['Kaleidoscope']
-- Description: get file_id, rows and columns for all files input to an image equivalence class
-- 

select
  file_id, pixel_rows, pixel_columns
from
  image_equivalence_class_input_image natural join file_image natural join image
where
  image_equivalence_class_id = ?