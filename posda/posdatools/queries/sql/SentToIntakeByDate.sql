-- Name: SentToIntakeByDate
-- Schema: posda_files
-- Columns: ['send_started', 'duration', 'destination_host', 'destination_port', 'to_send', 'files_sent', 'invoking_user', 'reason_for_send']
-- Args: ['from_date', 'to_date']
-- Tags: ['send_to_intake']
-- Description: List of Files Sent To Intake By Date
-- 

select
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
    send_started > ? and send_started < ?
  group by dicom_send_event_id
) as foo
natural join dicom_send_event
order by send_started
