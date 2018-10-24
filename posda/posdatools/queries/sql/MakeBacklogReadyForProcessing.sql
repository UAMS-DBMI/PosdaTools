-- Name: MakeBacklogReadyForProcessing
-- Schema: posda_backlog
-- Columns: []
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor']
-- Description: Mark Backlog as ready for Processor

update control_status
  set status = 'waiting to go inservice'
