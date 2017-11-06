-- Name: FileType
-- Schema: posda_files
-- Columns: ['file_type']
-- Args: ['file_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Get the file_type of a file, by file_id
-- 

select file_type
from file
where file_id = ?
