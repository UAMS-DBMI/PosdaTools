-- Name: AddProcessCount
-- Schema: posda_backlog
-- Columns: []
-- Args: ['process_count', 'round_id']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Set Process Count in round

update round
  set process_count = ?
where
  round_id = ?
