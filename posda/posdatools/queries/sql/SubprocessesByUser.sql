-- Name: SubprocessesByUser
-- Schema: posda_queries
-- Columns: ['subprocess_invocation_id', 'when_script_started', 'when_background_entered', 'when_script_ended', 'user_to_notify', 'button_name', 'operation_name', 'num_reports']
-- Args: ['invoking_user']
-- Tags: ['AllCollections', 'queries', 'activity_support']
-- Description: Get a list of available queries

select
  distinct subprocess_invocation_id, 
  when_script_started, when_background_entered, when_script_ended, user_to_notify, 
  button_name, operation_name, count(distinct background_subprocess_report_id) as num_reports 
from
  subprocess_invocation natural left join background_subprocess natural left join
  background_subprocess_report
where invoking_user = ?
group by
  subprocess_invocation_id, when_script_started, when_background_entered,
  when_script_ended, user_to_notify, button_name, operation_name
order by subprocess_invocation_id desc