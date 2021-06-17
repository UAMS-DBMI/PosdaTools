-- Name: ChangeFileType
-- Schema: posda_files
-- Columns: []
-- Args: ['file_type', 'file_id']
-- Tags: ['nifti']
-- Description: Change file_type of a file by file_id
-- 

update file
  set file_type = ?
where
  file_id = ?
