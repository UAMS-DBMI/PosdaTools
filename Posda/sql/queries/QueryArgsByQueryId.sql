-- Name: QueryArgsByQueryId
-- Schema: posda_queries
-- Columns: ['num', 'name', 'value']
-- Args: ['id']
-- Tags: ['AllCollections', 'q_stats']
-- Description: Get a list of collections and sites
-- 

select
  arg_index as num, arg_name as name, arg_value as value
from
  dbif_query_args
where
  query_invoked_by_dbif_id = ?
order by arg_index