-- Name: UnhideFile
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id']
-- Tags: ['ImageEdit', 'NotInteractive']
-- Description: Hide a file
-- 

update
  ctp_file
set
  visibility = null
where
  file_id = ?
