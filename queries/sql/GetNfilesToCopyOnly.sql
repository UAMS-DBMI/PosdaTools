-- Name: GetNfilesToCopyOnly
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'copy_file_path']
-- Args: ['copy_from_public_id', 'count']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  sop_instance_uid,
  copy_file_path 
from file_copy_from_public
where copy_from_public_id =  ? and inserted_file_id is null 
limit ?