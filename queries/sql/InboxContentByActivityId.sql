-- Name: InboxContentByActivityId
-- Schema: posda_queries
-- Columns: ['user_name', 'id', 'operation_name', 'when', 'file_id', 'command_line', 'spreadsheet_file_id']
-- Args: ['activity_id']
-- Tags: ['AllCollections', 'queries', 'activities']
-- Description: Get a list of available queries

select
 user_name, user_inbox_content_id as id, operation_name,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  activity_inbox_content natural join user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural join subprocess_invocation
  natural left join spreadsheet_uploaded
where activity_id = ?
order by when_invoked desc