-- Name: CancelQueryByPid
-- Schema: posda_backlog
-- Columns: ['pg_cancel_backend']
-- Args: ['pid']
-- Tags: ['AllCollections', 'postgres_stats', 'postgres_query_stats']
-- Description: Get a list of collections and sites
-- 

select 
  pg_cancel_backend(?)