-- Name: ActiveQueriesRunning
-- Schema: posda_backlog
-- Columns: ['datname', 'pid', 'time_query_running', 'query']
-- Args: []
-- Tags: ['AllCollections', 'postgres_stats', 'postgres_query_stats']
-- Description: Get a list of collections and sites
-- 

select 
  datname, pid,
  now() - query_start as time_query_running, 
  query
from pg_stat_activity
where
  state = 'active'
order by datname, state
