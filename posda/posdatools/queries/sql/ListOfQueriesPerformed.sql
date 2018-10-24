-- Name: ListOfQueriesPerformed
-- Schema: posda_queries
-- Columns: ['id', 'query_name', 'duration', 'invoked_by', 'at', 'number_of_rows']
-- Args: []
-- Tags: ['AllCollections', 'q_stats']
-- Description: Get a list of collections and sites
-- 

select
  query_invoked_by_dbif_id as id,
  query_name,
  query_end_time - query_start_time as duration,
  invoking_user as invoked_by,
  query_start_time as at, 
  number_of_rows
from
  query_invoked_by_dbif
