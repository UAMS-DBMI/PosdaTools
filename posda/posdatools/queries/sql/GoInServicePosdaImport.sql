-- Name: GoInServicePosdaImport
-- Schema: posda_files
-- Columns: []
-- Args: ['pid']
-- Tags: ['NotInteractive', 'PosdaImport']
-- Description: Claim control of posda_import

update import_control
set status = 'service process running',
  processor_pid = ?