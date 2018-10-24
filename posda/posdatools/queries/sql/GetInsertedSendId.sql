-- Name: GetInsertedSendId
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'SeriesSendEvent']
-- Description: Get dicom_send_event_id after creation
-- For use in scripts.
-- Not meant for interactive use
-- 

select currval('dicom_send_event_dicom_send_event_id_seq') as id
