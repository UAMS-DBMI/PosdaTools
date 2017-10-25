-- Name: UpdateSeriesFinished
-- Schema: posda_phi
-- Columns: []
-- Args: ['scan_event_id']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Update status to finished in scan event
-- 

update scan_event 
set scan_status = 'finished',
  scan_ended = now()
where scan_event_id = ?