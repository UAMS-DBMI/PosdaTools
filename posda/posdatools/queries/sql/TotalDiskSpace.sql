-- Name: TotalDiskSpace
-- Schema: posda_files
-- Columns: ['total_bytes']
-- Args: []
-- Tags: ['all', 'posda_files', 'storage_used']
-- Description: Get total disk space used
-- 

select
  sum(size) as total_bytes
from
  file
where
  file_id in (
  select distinct file_id
  from ctp_file
  )
