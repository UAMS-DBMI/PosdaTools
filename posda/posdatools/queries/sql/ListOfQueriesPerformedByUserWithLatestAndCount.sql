-- Name: ListOfQueriesPerformedByUserWithLatestAndCount
-- Schema: posda_queries
-- Columns: ['query_name', 'query', 'last_invocation', 'num_invocations', 'total_query_time', 'avg_query_time']
-- Args: ['user']
-- Tags: ['AllCollections', 'q_stats']
-- Description: Get a list of collections and sites
-- 

select
  distinct query_name, query,
  max(query_start_time) as last_invocation, 
  count(query_invoked_by_dbif_id) as num_invocations,
  sum(query_end_time - query_start_time) as total_query_time,
  avg(query_end_time - query_start_time) as avg_query_time
from 
  query_invoked_by_dbif i, queries q
where invoking_user = ? and i.query_name = q.name
group by query_name, query
order by last_invocation  desc