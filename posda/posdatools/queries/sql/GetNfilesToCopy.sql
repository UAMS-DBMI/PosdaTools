-- Name: GetNfilesToCopy
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'replace_file_id', 'copy_file_path']
-- Args: ['copy_from_public_id', 'count']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  c.sop_instance_uid,
  c.replace_file_id,
  c.copy_file_path
from file_copy_from_public c, ctp_file p
where
  c.copy_from_public_id = ? and
  (p.file_id = c.replace_file_id) and 
  (inserted_file_id is null)
limit ?