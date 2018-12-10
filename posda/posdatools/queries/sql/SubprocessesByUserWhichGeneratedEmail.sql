-- Name: SubprocessesByUserWhichGeneratedEmail
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'button_name', 'operation_name', 'user_inbox_content_id', 'activity_id', 'activity_description', 'command_line']
-- Args: ['invoking_user']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select 
  distinct subprocess_invocation_id, when_script_started, when_background_entered,
  when_script_ended, user_to_notify, button_name, operation_name, command_line,
  user_inbox_content_id, activity_id, brief_description as activity_description
from
  subprocess_invocation natural left join background_subprocess natural left join 
  background_subprocess_report natural left join user_inbox_content natural left join
  activity_inbox_content left join activity using (activity_id)
where
  invoking_user = ? and background_subprocess_report.name = 'Email'
order by subprocess_invocation_id desc;