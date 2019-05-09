-- Name: ListOfQueriesPerformedAllWithLatestAndCountAndUser
-- Schema: posda_queries
-- Columns: ['invoking_user', 'query_name', 'last_invocation', 'num_invocations', 'total_query_time', 'avg_query_time']
-- Args: []
-- Tags: ['AllCollections', 'q_stats']
-- Description: Get a list of collections and sites
-- 

select
  distinct invoking_user, query_name,
  max(query_start_time) as last_invocation, 
  count(query_invoked_by_dbif_id) as num_invocations,
  sum(query_end_time - query_start_time) as total_query_time,
  avg(query_end_time - query_start_time) as avg_query_time
from 
  query_invoked_by_dbif
group by invoking_user, query_name
order by last_invocation  desc