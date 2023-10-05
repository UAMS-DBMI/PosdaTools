-- Name: HowManyFilesToHideInCopyFromPublic
-- Schema: posda_files
-- Columns: ['num_to_hide']
-- Args: ['copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  count(*) as num_to_hide
from file_copy_from_public c, ctp_file p
where
  c.copy_from_public_id = ? and
  (p.file_id = c.replace_file_id) 