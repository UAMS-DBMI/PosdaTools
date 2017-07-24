-- Name: SeriesSendEventsByReason
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'send_started', 'duration', 'destination_host', 'destination_port', 'to_send', 'files_sent', 'invoking_user', 'reason_for_send']
-- Args: ['reason']
-- Tags: ['send_to_intake']
-- Description: List of Send Events By Reason
-- 

select
  series_to_send as series_instance_uid,
  send_started, send_ended - send_started as duration,
  destination_host, destination_port,
  number_of_files as to_send, files_sent,
  invoking_user, reason_for_send
from (
  select
    distinct dicom_send_event_id,
    count(distinct file_path) as files_sent
  from
    dicom_send_event natural join dicom_file_send
  where
    reason_for_send = ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
