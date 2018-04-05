-- Name: GetQuery
-- Schema: posda_backlog
-- Columns: ['query']
-- Args: ['pid']
-- Tags: ['AllCollections', 'postgres_stats', 'postgres_query_stats']
-- Description: Get a list of collections and sites
-- 

select 
 query
from pg_stat_activity
where pid = ?