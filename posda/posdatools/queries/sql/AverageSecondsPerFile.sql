-- Name: AverageSecondsPerFile
-- Schema: posda_files
-- Columns: ['avg']
-- Args: ['from_date', 'to_date']
-- Tags: ['send_to_intake']
-- Description: Average Time to send a file between times
-- 

select avg(seconds_per_file) from (
  select (send_ended - send_started)/number_of_files as seconds_per_file 
  from dicom_send_event where send_ended is not null and number_of_files > 0
  and send_started > ? and send_ended < ?
) as foo
