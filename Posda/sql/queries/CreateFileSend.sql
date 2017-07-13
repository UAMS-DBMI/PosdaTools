-- Name: CreateFileSend
-- Schema: posda_files
-- Columns: None
-- Args: ['id', 'path', 'status', 'file_id']
-- Tags: ['NotInteractive', 'SeriesSendEvent']
-- Description: Add a file send row
-- For use in scripts.
-- Not meant for interactive use
-- 

insert into dicom_file_send(
  dicom_send_event_id, file_path, status, file_id_sent
) values (
  ?, ?, ?, ?
)
returning dicom_send_event_id
