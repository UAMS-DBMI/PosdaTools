-- Name: ActivityCrossTalkSeries
-- Schema: posda_backlog
-- Columns: []
-- Args: ['round_id']
-- Tags: ['NotInteractive', 'Backlog']
-- Description:  Close row in round (set end time)
-- 

update round
  set round_aborted = now()
where
  round_id = ?
