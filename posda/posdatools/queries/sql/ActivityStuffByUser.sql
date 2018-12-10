-- Name: ActivityStuffByUser
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'background_subprocess_id', 'user_inbox_content_id', 'activity_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'button_name', 'operation_name', 'num_reports']
-- Args: ['user']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

select
  distinct subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  activity_id, when_script_started,
  when_background_entered, when_script_ended, user_to_notify, button_name,
  operation_name, count(distinct background_subprocess_report_id) as num_reports
from
  subprocess_invocation natural left join background_subprocess natural left join background_subprocess_report
  natural left join user_inbox_content natural left join activity_inbox_content
where invoking_user = ?
group by
  subprocess_invocation_id, background_subprocess_id, user_inbox_content_id,
  activity_id, when_script_started, when_background_entered,
  when_script_ended, user_to_notify, button_name, operation_name
order by subprocess_invocation_id desc