-- Name: InboxContentByDateRange
-- Schema: posda_queries
-- Columns: ['activity_id', 'activity_description', 'user_name', 'user_inbox_content_id', 'operation_name', 'when', 'file_id', 'sub_id', 'command_line', 'spreadsheet_file_id']
-- Args: ['from', 'to']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
  activity_id, brief_description as activity_description,
  user_name, user_inbox_content_id, operation_name,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  activity natural join activity_inbox_content natural join user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural join subprocess_invocation
  natural left join spreadsheet_uploaded
where 
  when_script_started > ? and when_script_started < ?
order by activity_id, when_script_started