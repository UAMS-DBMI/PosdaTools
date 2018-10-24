-- Name: LongestRunningNQueriesByDate
-- Schema: posda_queries
-- Columns: ['id', 'query_name', 'duration', 'invoking_user', 'query_start_time', 'number_of_rows']
-- Args: ['from', 'to', 'n']
-- Tags: ['AllCollections', 'q_stats_by_date']
-- Description: Get a list of collections and sites
-- 

select * from (
select query_invoked_by_dbif_id as id, query_name, query_end_time - query_start_time as duration,
invoking_user, query_start_time, number_of_rows
from query_invoked_by_dbif
where query_end_time is not null and
query_start_time > ? and query_end_time < ?
order by duration desc) as foo
limit ?