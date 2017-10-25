-- Name: GetPosdaFilesImportControl
-- Schema: posda_files
-- Columns: ['status', 'processor_pid', 'idle_seconds', 'pending_change_request', 'files_per_round']
-- Args: []
-- Tags: ['NotInteractive', 'PosdaImport']
-- Description: Get import control status from posda_files database

select
  status,
  processor_pid,
  idle_seconds,
  pending_change_request,
  files_per_round
from
  import_control