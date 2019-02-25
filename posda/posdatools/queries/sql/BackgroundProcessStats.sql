-- Name: BackgroundProcessStats
-- Schema: posda_files
-- Columns: ['command_executed', 'longest', 'shortest', 'avg', 'times_invoked', 'num_invokers', 'first', 'last']
-- Args: []
-- Tags: ['AllCollections', 'postgres_stats', 'postgres_query_stats']
-- Description: Get a list of collections and sites
-- 

select
  distinct command_executed, max(when_script_ended - when_script_started) as longest,
  min(when_script_ended - when_script_started) as shortest,
  avg(when_script_ended - when_script_started) as avg, count(*) as times_invoked,
  count(distinct invoking_user) as num_invokers,
  min(when_script_started) as first, max(when_script_started) as last
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null
group by command_executed
order by last desc, times_invoked desc