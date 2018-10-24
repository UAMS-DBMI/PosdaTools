-- Name: SendEventSummary
-- Schema: posda_files
-- Columns: ['reason_for_send', 'num_events', 'files_sent', 'earliest_send', 'finished', 'duration']
-- Args: []
-- Tags: ['send_to_intake']
-- Description: Summary of SendEvents by Reason
-- 

select
  reason_for_send, num_events, files_sent, earliest_send,
  finished, finished - earliest_send as duration
from (
  select
    distinct reason_for_send, count(*) as num_events, sum(number_of_files) as files_sent,
    min(send_started) as earliest_send, max(send_ended) as finished
  from dicom_send_event
  group by reason_for_send
  order by earliest_send
) as foo
