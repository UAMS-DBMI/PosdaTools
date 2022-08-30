-- Name: RecentFileImports
-- Schema: posda_files
-- Columns: ['file_id', 'file_name', 'import_time']
-- Args: ['interval']
-- Tags: ['TempMprVolume']
-- Description: Get Rent File Imports
-- 

select
  file_id, file_name, file_import_time
from file_import
where (now() - file_import_time) < cast( ? as interval);