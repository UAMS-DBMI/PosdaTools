-- Name: AddNiftiExtraFile
-- Schema: posda_files
-- Columns: []
-- Args: ['nifti_file_from_series_id', 'nifti_extra_file_id', 'nifti_extra_file_nae']
-- Tags: ['nifti']
-- Description: Create row in nifti_extra_file_from_series table
-- 

insert into nifti_extra_file_from_series(
  nifti_file_from_series_id,
  nifti_extra_file_id,
  nifti_extra_file_name
) values (
  ?, ?, ?
)