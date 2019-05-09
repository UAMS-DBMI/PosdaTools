-- Name: BackgroundersByDateRange
-- Schema: posda_files
-- Columns: ['operation_name', 'num_invocations']
-- Args: ['from', 'to']
-- Tags: ['invoking_user']
-- Description: Get a list of collections and sites
-- 

select
  distinct operation_name, count(distinct subprocess_invocation_id) as num_invocations
from
  background_subprocess natural join subprocess_invocation
where
  when_script_ended is not null and operation_name is not null and
  when_script_started > ? and when_script_ended < ? and
  when_script_ended is not null
group by operation_name
order by num_invocations desc