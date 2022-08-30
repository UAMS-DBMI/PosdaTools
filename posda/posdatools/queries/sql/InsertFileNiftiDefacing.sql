-- Name: InsertFileNiftiDefacing
-- Schema: posda_files
-- Columns: ['id']
-- Args: ['nifti_file_id', 'comment']
-- Tags: ['nifti']
-- Description: Create row in file_nifti_defacing table
-- 

insert into file_nifti_defacing(
  operation, from_nifti_file, comments
) values (
  'deface',
  ?, ?
)
returning file_nifti_defacing_id as id