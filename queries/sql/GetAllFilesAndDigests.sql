-- Name: GetAllFilesAndDigests
-- Schema: posda_backlog
-- Columns: ['received_file_path', 'digest']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Get all files with digests in backlog

select 
  received_file_path, file_digest
from 
  request

