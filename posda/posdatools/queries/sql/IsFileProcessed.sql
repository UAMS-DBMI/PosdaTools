-- Name: IsFileProcessed
-- Schema: posda_files
-- Columns: ['processed']
-- Args: ['file_id']
-- Tags: []
-- Description: 
-- 

select is_dicom_file is not null as processed
from file
where file_id = ?
