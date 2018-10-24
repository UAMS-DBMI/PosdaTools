-- Name: RequestShutdown
-- Schema: posda_backlog
-- Columns: []
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor']
-- Description: request a shutdown of Backlog processing

update control_status
  set pending_change_request = 'shutdown',
  source_pending_change_request = 'DbIf',
  request_time = now()