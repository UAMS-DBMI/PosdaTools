-- Name: GetIdOfNewCopyFromPublicRow
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['bills_test', 'copy_from_public']
-- Description: Add a filter to a tab

select currval('copy_from_public_copy_from_public_id_seq') as id