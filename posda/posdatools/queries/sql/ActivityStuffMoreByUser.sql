-- Name: ActivityStuffMoreByUser
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'background_subprocess_report_id', 'file_id', 'report_type', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'invoking_user', 'user_to_notify', 'button_name', 'operation_name', 'command_line']
-- Args: ['user']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  background_subprocess_report_id, file_id,
  background_subprocess_report.name as report_type,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, 
  invoking_user, user_to_notify, button_name,
  operation_name, command_line
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ?
order by subprocess_invocation_id desc
