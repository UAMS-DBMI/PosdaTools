-- Name: BackgroundProcessStatsWithInvokerLikeComand
-- Schema: posda_files
-- Columns: ['operation_name', 'command_executed', 'invoker', 'longest', 'shortest', 'avg', 'times_invoked', 'first', 'last']
-- Args: ['operation_name_like']
-- Tags: ['AllCollections', 'postgres_stats', 'postgres_query_stats']
-- Description: Get a list of collections and sites
-- 

select
  distinct operation_name, command_executed, invoking_user as invoker, 
  max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and operation_name like ?
group by operation_name, command_executed, invoker