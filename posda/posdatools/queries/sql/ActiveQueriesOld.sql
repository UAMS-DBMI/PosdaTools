-- Name: ActiveQueriesOld
-- Schema: posda_files
-- Columns: ['db_name', 'pid', 'user_id', 'user', 'waiting', 'since_xact_start', 'since_query_start', 'since_back_end_start', 'current_query']
-- Args: ['db_name']
-- Tags: ['postgres_status']
-- Description: Show active queries for a database
-- Works for PostgreSQL 8.4.20 (Current Linux)
-- 

select
  datname as db_name, procpid as pid,
  usesysid as user_id, usename as user,
  waiting, now() - xact_start as since_xact_start,
  now() - query_start as since_query_start,
  now() - backend_start as since_back_end_start,
  current_query
from
  pg_stat_activity
where
  datname = ?
