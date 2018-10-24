-- Name: HowManyRowsInCopyFromPublic
-- Schema: posda_files
-- Columns: ['num_copies_total']
-- Args: ['copy_from_public_id']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select
  count(*) as num_copies_total
from file_copy_from_public c
where
  c.copy_from_public_id = ? 