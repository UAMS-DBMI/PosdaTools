-- Name: BackgroundProcessStatsWithInvoker
-- Schema: posda_files
-- Columns: ['command_executed', 'invoker', 'longest', 'shortest', 'avg', 'times_invoked', 'first', 'last']
-- Args: []
-- Tags: ['invoking_user']
-- Description: Get a list of collections and sites
-- 

select
  distinct command_executed, invoking_user as invoker, 
  max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null
group by command_executed, invoker