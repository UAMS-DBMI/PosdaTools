-- Name: CreateCopyFromPublicEntry
-- Schema: posda_files
-- Columns: []
-- Args: ['who', 'why', 'status_of_copy']
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

insert into copy_from_public(
  who, why, when_row_created, status_of_copy
) values (
  ?, ?, now(), ?
)