-- Name: InboxContentByActivityId
-- Schema: posda_queries
-- Columns: ['user_name', 'id', 'operation_name', 'when', 'file_id', 'sub_id', 'command_line', 'spreadsheet_file_id']
-- Args: ['activity_id']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
 user_name, user_inbox_content_id as id, operation_name,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  activity_inbox_content natural left join user_inbox natural left join
  user_inbox_content natural left join background_subprocess_report
  natural join background_subprocess natural left join subprocess_invocation
  natural left join spreadsheet_uploaded
where activity_id = ?
order by when_script_started desc