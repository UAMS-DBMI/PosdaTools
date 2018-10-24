-- Name: QueriesRunning
-- Schema: posda_backlog
-- Columns: ['datname', 'pid', 'time_backend_running', 'time_query_running', 'time_since_state_change', 'state']
-- Args: []
-- Tags: ['AllCollections', 'postgres_stats', 'postgres_query_stats']
-- Description: Get a list of collections and sites
-- 

select 
  datname, pid,
  now() - backend_start as time_backend_running,
  now() - query_start as time_query_running, 
  now() - state_change as time_since_state_change,
  state
from pg_stat_activity
  order by datname, state