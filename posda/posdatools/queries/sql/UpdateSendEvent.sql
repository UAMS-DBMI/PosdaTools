-- Name: UpdateSendEvent
-- Schema: posda_files
-- Columns: None
-- Args: ['id']
-- Tags: ['NotInteractive', 'SeriesSendEvent']
-- Description: Update dicom_send_event_id after creation and completion of send
-- For use in scripts.
-- Not meant for interactive use
-- 

update dicom_send_event
  set send_ended = now()
where dicom_send_event_id = ?
