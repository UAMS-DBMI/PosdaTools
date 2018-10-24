-- Name: CloseRound
-- Schema: posda_backlog
-- Columns: []
-- Args: ['round_id']
-- Tags: ['NotInteractive', 'Backlog']
-- Description: Close row in round (set end time)

update round
  set round_end = now()
where
  round_id = ?
