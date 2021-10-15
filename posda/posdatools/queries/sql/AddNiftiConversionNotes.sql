-- Name: AddNiftiConversionNotes
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_from_series_id', 'note']
-- Tags: ['nifti']
-- Description: Create row in file_nifti table
-- 

insert into nifti_conversion_notes(
  nifti_file_from_series_id,
  note
) values (
  ?, ?
)