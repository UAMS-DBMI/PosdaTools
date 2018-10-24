-- Name: RelinquishControlPosdaImport
-- Schema: posda_files
-- Columns: []
-- Args: []
-- Tags: ['NotInteractive', 'PosdaImport']
-- Description: relese control of posda_import

update import_control
set status = 'idle',
  processor_pid =  null,
  pending_change_request = null