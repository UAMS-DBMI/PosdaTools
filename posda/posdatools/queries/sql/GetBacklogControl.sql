-- Name: GetBacklogControl
-- Schema: posda_backlog
-- Columns: ['status', 'processor_pid', 'idle_poll_interval', 'last_service', 'pending_change_request', 'source_pending_change_request', 'request_time', 'num_files_per_round', 'target_queue_size', 'time_pending']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor']
-- Description: Get control status from backlog database

select
  status, processor_pid,
  idle_poll_interval,
  last_service, pending_change_request,
  source_pending_change_request,
  request_time, num_files_per_round,
  target_queue_size,
  (now() - request_time) as time_pending
from control_status
