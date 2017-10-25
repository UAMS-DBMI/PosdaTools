-- Name: InsertSendEvent
-- Schema: posda_files
-- Columns: None
-- Args: ['host', 'port', 'called', 'calling', 'who', 'why', 'num_files', 'series']
-- Tags: ['NotInteractive', 'SeriesSendEvent']
-- Description: Create a DICOM Series Send Event
-- For use in scripts.
-- Not meant for interactive use
-- 

insert into dicom_send_event(
  destination_host, destination_port,
  called_ae, calling_ae,
  send_started, invoking_user,
  reason_for_send, number_of_files,
  is_series_send, series_to_send
)values(
  ?, ?,
  ?, ?,
  now(), ?,
  ?, ?,
  true, ?
)
