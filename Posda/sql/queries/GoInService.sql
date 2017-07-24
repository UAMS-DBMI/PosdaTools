-- Name: GoInService
-- Schema: posda_backlog
-- Columns: []
-- Args: ['pid']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Claim control of posda_backlog

update control_status
set status = 'service process running',
  processor_pid = ?