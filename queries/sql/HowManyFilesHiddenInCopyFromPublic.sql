-- Name: HowManyFilesHiddenInCopyFromPublic
-- Schema: posda_files
-- Columns: ['num_hidden']
-- Args: ['copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  count(*) as num_hidden
from file_copy_from_public c, ctp_file p
where
  c.copy_from_public_id = ? and
  (p.file_id = c.replace_file_id and p.visibility is not null) 