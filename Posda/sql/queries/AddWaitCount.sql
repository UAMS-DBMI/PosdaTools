-- Name: AddWaitCount
-- Schema: posda_backlog
-- Columns: []
-- Args: ['wait_count', 'round_id']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Set wait_count in round

update round
  set wait_count = ?
where
  round_id = ?
