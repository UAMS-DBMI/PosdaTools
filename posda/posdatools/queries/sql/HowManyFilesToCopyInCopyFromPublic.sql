-- Name: HowManyFilesToCopyInCopyFromPublic
-- Schema: posda_files
-- Columns: ['num_to_copy']
-- Args: ['copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  count(*) as num_to_copy
from file_copy_from_public
where
  copy_from_public_id = ? and
  inserted_file_id is null