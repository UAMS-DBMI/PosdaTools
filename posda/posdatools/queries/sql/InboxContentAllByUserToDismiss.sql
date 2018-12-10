-- Name: InboxContentAllByUserToDismiss
-- Schema: posda_queries
-- Columns: ['user_name', 'id', 'operation_name', 'current_status', 'activity_id', 'brief_description', 'when', 'file_id', 'command_line', 'spreadsheet_file_id']
-- Args: ['user_name']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
 user_name, user_inbox_content_id as id, operation_name,
  current_status,
  activity_id, brief_description,
  when_script_started as when, 
  file_id, subprocess_invocation_id as sub_id,
  command_line,
  file_id_in_posda as spreadsheet_file_id
from 
  user_inbox natural join
  user_inbox_content natural join background_subprocess_report
  natural join background_subprocess natural left join subprocess_invocation
  natural left join spreadsheet_uploaded
  natural left join activity_inbox_content natural left join
  activity
where user_name = ? and activity_id is null and current_status != 'dismissed'
order by user_inbox_content_id desc