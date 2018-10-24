-- Name: GetCurrentPosdaFileId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'used_in_file_import_into_posda']
-- Description: Get posda file id of created file row

select  currval('file_file_id_seq') as id
