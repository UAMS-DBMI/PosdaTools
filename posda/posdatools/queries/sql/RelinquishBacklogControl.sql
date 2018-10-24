-- Name: RelinquishBacklogControl
-- Schema: posda_backlog
-- Columns: []
-- Args: []
-- Tags: ['NotInteractive', 'Backlog']
-- Description: relese control of posda_backlog

update control_status
set status = 'idle',
  processor_pid =  null,
  pending_change_request = null,
  source_pending_change_request = null,
  request_time = null